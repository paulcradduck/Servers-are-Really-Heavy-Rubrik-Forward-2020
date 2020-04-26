
//Variables

//Landing Zone Location
variable "Landing_Zone_Location" {
  default = "East US"
}

//Landing Zone Tags
variable "Landing_Zone_Tag" {
  default = "Prod"
}

//Landing Zone Resource Group Name
variable "Resource_Group_Name" {
  default = "Default_Azure_RG"
}

//vNet Name
variable "vNet_Name" {
  default = "Default_Azure_vNet"
}

//vNet Name
variable "vNet_IP_Space" {
  default = ["10.0.0.0/16"]
}

//vNet Name
variable "vNet_DNS" {
  default = ["8.8.8.8", "8.8.4.4"]
}

//AzureBastionSubnet
variable "AzureBastionSubnet_address_prefix" {
  default = "10.0.0.0/24"
}

//SubNet 1 Name
variable "Subnet_1_Name" {
  default = "Default_Azure_SubNet_1"
}
variable "Subnet_1_address_prefix" {
  default = "10.0.20.0/24"
}

//SubNet 2 Name
variable "Subnet_2_Name" {
  default = "Default_Azure_SubNet_2"
}
variable "Subnet_2_address_prefix" {
  default = "10.0.30.0/24"
}

//SubNet 3 Name
variable "Subnet_3_Name" {
  default = "Default_Azure_SubNet_3"
}
variable "Subnet_3_address_prefix" {
  default = "10.0.40.0/24"
}

variable "Landing_Zone_NSG_Name" {
  default = "Landing_Zone_NSG"
}

variable "Landing_Zone_Storage_Account_Name" {
  default = "vcdx244storageaccount"
}

//  1. Ensure you edit security rules in section: "azurerm_network_security_rule" "Security_Rule_1"
//
//*****************************************************************
//                  Begin Landing Zone Code                       *
//*****************************************************************

//Resource Group
resource "azurerm_resource_group" "Landing_Zone_RG" {
  name     = var.Resource_Group_Name
  location = var.Landing_Zone_Location

  tags = {
    environment = var.Landing_Zone_Tag
  }
}

//vNET
resource "azurerm_virtual_network" "Landing_Zone_vNet" {
  name                = var.vNet_Name
  location            = var.Landing_Zone_Location
  resource_group_name = azurerm_resource_group.Landing_Zone_RG.name
  address_space       = var.vNet_IP_Space
  dns_servers         = var.vNet_DNS

    tags = {
    environment = var.Landing_Zone_Tag
  }

  }
//Subnet
resource "azurerm_subnet" "Azure_Landing_Zone_Sub_1" {
  name = var.Subnet_1_Name
  resource_group_name = azurerm_resource_group.Landing_Zone_RG.name
  virtual_network_name = azurerm_virtual_network.Landing_Zone_vNet.name
  address_prefix = var.Subnet_1_address_prefix
}
//Subnet
resource "azurerm_subnet" "Azure_Landing_Zone_Sub_2" {
  name = var.Subnet_2_Name
  resource_group_name = azurerm_resource_group.Landing_Zone_RG.name
  virtual_network_name = azurerm_virtual_network.Landing_Zone_vNet.name
  address_prefix = var.Subnet_2_address_prefix
  }
//Subnet
resource "azurerm_subnet" "Azure_Landing_Zone_Sub_3" {
  name = var.Subnet_3_Name
  resource_group_name = azurerm_resource_group.Landing_Zone_RG.name
  virtual_network_name = azurerm_virtual_network.Landing_Zone_vNet.name
  address_prefix = var.Subnet_3_address_prefix
}
// Azure Bastion Subnet - DO NOT CHNAGE THE NAME - Bastion Service Requires the AzureBastionSubnet as the name
resource "azurerm_subnet" "Landing_Zone-AzureBastionSubnet" {
  name = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.Landing_Zone_RG.name
  virtual_network_name = azurerm_virtual_network.Landing_Zone_vNet.name
  address_prefix = var.AzureBastionSubnet_address_prefix

}


//Landing Zone NSG
resource "azurerm_network_security_group" "Azure_Landing_Zone_NSG" {
  name                = var.Landing_Zone_NSG_Name
  location            = azurerm_resource_group.Landing_Zone_RG.location
  resource_group_name = azurerm_resource_group.Landing_Zone_RG.name
}


resource "azurerm_network_security_rule" "Security_Rule_1" {
  name                        = "Azure Landing Zone Rule 1"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Landing_Zone_RG.name
  network_security_group_name = azurerm_network_security_group.Azure_Landing_Zone_NSG.name
}


//Bastion Service Setup
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "bastion_public_ip"
  location            = azurerm_resource_group.Landing_Zone_RG.location
  resource_group_name = azurerm_resource_group.Landing_Zone_RG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "Azure_Landing_Zone_bastion_host" {
  name                = "BastionService"
  location            = azurerm_resource_group.Landing_Zone_RG.location
  resource_group_name = azurerm_resource_group.Landing_Zone_RG.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.Landing_Zone-AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}

resource "azurerm_storage_account" "Azure_Landing_Zone_Storage_Account" {
  name                     = var.Landing_Zone_Storage_Account_Name
  resource_group_name      = azurerm_resource_group.Landing_Zone_RG.name
  location                 = azurerm_resource_group.Landing_Zone_RG.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = var.Landing_Zone_Tag
  }
}

