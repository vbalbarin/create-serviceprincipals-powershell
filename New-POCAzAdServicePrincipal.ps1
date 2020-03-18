function New-POCAzAdServicePrincipal {
  [Cmdletbinding()]

  param(
    [Parameter()]
    [String]
    $SaasAppName,

    [Parameter()]
    [String]
    $Plaintext,

    [Parameter()]
    [Int]
    $POCDays = 15
  )

  try {
    $AZURE_TENANTID = (Get-AzContext).Tenant.Id
    if ($AZURE_TENANTID.Length -eq 0) { Throw "Not logged into an Azure." }

    $AZURE_SAAS_SOLUTION = $SaasAppName
    $AZURE_SAAS_POC_DURATION = $POCDays


    $credentialParms = @{
      TypeName = 'Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential'
      Property = @{
        StartDate = Get-Date
        EndDate = $(Get-Date).AddDays($AZURE_SAAS_POC_DURATION)
        Password = $Plaintext
      }
    }
    $credentials = New-Object @credentialParms

    # Create Service Principal
    $AZURE_SP = New-AzADServicePrincipal -DisplayName $AZURE_SAAS_SOLUTION `
                                         -PasswordCredential $credentials

    return [PSCustomObject]@{
      DisplayName = $AZURE_SAAS_SOLUTION
      ClientId = $AZURE_SP.ApplicationId.Guid
      TenantId = $AZURE_TENANTID
      Secret = $Plaintext
      Expiry = $AZURE_SP_CRED_EXPIRY
    }
  } catch {
    Write-Host ("ERROR: {0}" -f $_.Exception.Message)
  }

}