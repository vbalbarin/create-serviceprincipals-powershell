function New-POCAzAdServicePrincipal {
  [Cmdletbinding()]

  param(
    [Parameter()]
    [String]
    $SaasAppName,

    [Parameter()]
    [String]
    $Plaintext = $(New-Guid),

    [Parameter()]
    [Int]
    $DurationDays = 15
  )

  try {
    $tenantId = (Get-AzContext).Tenant.Id
    if ($tenantId.Length -eq 0) { Throw "Not logged into an Azure." }
      $currentDate = Get-Date
      $expirationDate = $currentDate.AddDays($DurationDays)
      $credentialParms = @{
      TypeName = 'Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential'
      Property = @{
        StartDate = $currentDate
        EndDate = $expirationDate
        Password = $Plaintext
      }
    }
    $credentials = New-Object @credentialParms

    # Create Service Principal
    $servicePrincipal = New-AzADServicePrincipal -DisplayName $SaasAppName `
                                         -PasswordCredential $credentials

    return [PSCustomObject]@{
      DisplayName = $SaasAppName
      ClientId = $servicePrincipal.ApplicationId.Guid
      TenantId = $tenantId
      Secret = $Plaintext
      Expiry = $expirationDate
    }
  } catch {
    Write-Host ("ERROR: {0}" -f $_.Exception.Message)
  }

}