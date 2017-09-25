#-----------------------------------------------------------
#         Virtual Network, Subnet, VM deteails like
#-----------------------------------------------------------

#Press F5 button to run this script#

&lt;#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#&gt;


$SubscriptionName = Get-AzureRmSubscription -SubscriptionName 'EY – FACS ChildStory – Development'
$Resourceobjs = @()
$vnetworks = Get-AzureRmVirtualNetwork
$virtualNetworks=foreach($vnetwork in $vnetworks)
{
    $Subs = $vnetwork.Subnets
    $subnets=foreach($sub in $subs)
        {
        $Vnics = Get-AzureRmNetworkInterface |Where {$_.IpConfigurations.Subnet.Id -eq $sub.id}
        $virtualNICS =foreach($Vnic in $Vnics)
            {
                $VM = Get-azureRMVM | Where {$_.Id -eq $Vnic.VirtualMachine.Id}
                $vmStatus = $VM | Get-AzureRmVM -Status

                        [pscustomobject]@{
                                            SubscriptionName = $SubscriptionName.Name
                                            ProjectName = if(($VM.Tags) -ne $null){$VM.Tags.GetEnumerator()-join "**" | Sort-Object};
                                            VMName = $VM.Name
                                            OSType = $VM.StorageProfile.OsDisk.OsType
                                            OSFalvour = $VM.StorageProfile.ImageReference.Offer
                                            OSVersion = $VM.StorageProfile.ImageReference.Sku
                                            OSPublisher = $VM.StorageProfile.ImageReference.Publisher
                                            DataDisk = $VM.StorageProfile.DataDisks.vhd.uri -join "**"
                                            PricingTier = $VM.HardwareProfile.VmSize
                                            Status = $vmStatus.Statuses[1].DisplayStatus
                                            Region = $VM.Location
                                            VirtualNetworkName = $vnetwork.Name
                                            SubnetAddressprefix=$sub.AddressPrefix
                                            PrivateIpAddress = $Vnic.IpConfigurations.PrivateIpAddress
                                            VMResourceGroupName = $VM.ResourceGroupName
                                         }
            }
            #Subnet
               [pscustomobject]@{
                                    SubnetName=$sub.Name
                                    Addressprefix=$sub.AddressPrefix
                                    NetWorkSecuritygroup=$NetworkSecurityGroup.Name
                                    RouteTable=$RouteTable.Name
                                    Vnics = $virtualNICS
                                }
            }
        #Network
        [pscustomobject]@{
                            NetworkName = $vnetwork.Name
                            ResourceGroup=$vnetwork.ResourceGroupName
                            AddressPrefixes = $vnetwork.AddressSpace.AddressPrefixes
                            DNS = $vnetwork.DhcpOptions.DnsServers
                            Subnets = $subnets
                            Vnics = $virtualNICS
                        }
$Resourceobjs += $subnets.Vnics
}
$csvVirtualNetworkpath = $Directory.FullName + "C:\ScriptOutput\FACSVMDetails.csv"
$csvVirtualNetwork = $Resourceobjs  |Export-Csv $csvVirtualNetworkpath -NoTypeInformation

##$csvVirtualNetworkpath = $Directory.FullName + "C:\ScriptOutput\" + $vnetwork.Name + "-Network.csv"
##$csvVirtualNetwork = $subnets.Vnics  |Export-Csv $csvVirtualNetworkpath -NoTypeInformation
#https://technet.microsoft.com/en-us/library/ee692803.aspx - Hash table value retriving
