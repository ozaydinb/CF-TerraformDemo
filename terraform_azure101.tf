variable "location" {
    type="string"
    default="westeurope"
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "your_subscription_id"
  client_id       = "your_client_id"
  client_secret   = "your_client_secret"
  tenant_id       = "your_tenant_id"
}

# create a resource group 
resource "azurerm_resource_group" "codefiction" {
    name = "cfdemo"
    location = "${var.location}"
}

# create a virtual network
resource "azurerm_virtual_network" "cfnetwork" {
    name = "cfvn"
    address_space = ["10.0.0.0/16"]
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.codefiction.name}"
}

# create subnet
resource "azurerm_subnet" "cfsubnet" {
    name = "cfsub"
    resource_group_name = "${azurerm_resource_group.codefiction.name}"
    virtual_network_name = "${azurerm_virtual_network.cfnetwork.name}"
    address_prefix = "10.0.2.0/24"
}

# create public IP
resource "azurerm_public_ip" "cfpublicip" {
    name = "cfpublictestip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.codefiction.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "CodeFictionTerraformDemo"
    }
}

# create network interface
resource "azurerm_network_interface" "cftestnetworkint" {
    name = "cfni"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.codefiction.name}"

    ip_configuration {
        name = "cftestconfig"
        subnet_id = "${azurerm_subnet.cfsubnet.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.0.2.5"
        public_ip_address_id = "${azurerm_public_ip.cfpublicip.id}"
    }
}

# create storage account
resource "azurerm_storage_account" "cfstorage" {
    name = "cfsacc"
    resource_group_name = "${azurerm_resource_group.codefiction.name}"
    location = "${var.location}"
    account_tier = "Standard"
    account_replication_type= "GRS"

    tags {
        environment = "staging"
    }
}

# create storage container
resource "azurerm_storage_container" "cfstoragecontainer" {
    name = "vhd"
    resource_group_name = "${azurerm_resource_group.codefiction.name}"
    storage_account_name = "${azurerm_storage_account.cfstorage.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.cfstorage"]
}

# create virtual machine
resource "azurerm_virtual_machine" "cfdemovm" {
    name = "cfvm1"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.codefiction.name}"
    network_interface_ids = ["${azurerm_network_interface.cftestnetworkint.id}"]
    vm_size = "Standard_A0"

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "14.04.2-LTS"
        version = "latest"
    }

    storage_os_disk {
        name = "myosdisk"
        vhd_uri = "${azurerm_storage_account.cfstorage.primary_blob_endpoint}${azurerm_storage_container.cfstoragecontainer.name}/myosdisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "cfubuntuhost"
        admin_username = "codefiction"
        admin_password = "Password0!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags {
        environment = "staging"
    }
}