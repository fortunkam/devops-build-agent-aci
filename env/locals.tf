locals {
    rg_name = "${var.prefix}-rg"
    vnet_name = "${var.prefix}-vnet"
    vnet_iprange = "10.0.0.0/16"
    acr_name = "${var.prefix}acr"
    aci_subnet = "aci"
    aci_subnet_iprange = "10.0.0.0/24"
    aci_sp_app_name = "${var.prefix}-aci-sp"


}