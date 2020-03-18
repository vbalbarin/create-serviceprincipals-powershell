# azure-saas-monitoring-poc
Azure Powershell code setup integration with SaaS enterprise monitoring

## Provisioing Service Principal and Role for POC

```powershell
# Logon to Azure
Connect-AzAccount -SubscriptionName '<% SUBSCRIPTION_NAME %>'

# Dot source commandlet
. "./scripts/New-POCAzAdServicePrincipal.ps1"

$AZURE_SAAS_SOLUTION = '<% APPLICATION_NAME %>'

# Create service account
$AZURE_POC_SP = New-POCAzAdServicePrincipal -SaasAppName $AZURE_SAAS_SOLUTION

$AZURE_POC_SP
# Sample Output
# DisplayName : <% APPLICATION_NAME %>
# ClientId    : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# TenantId    : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# Secret      : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# Expiry      : 3/18/20 5:05:08 PM
# These values should be copied over to the SaaS solution console. Expiry is set at 15 days from account creation.

# Assign Reader role over desired subscription scopes
Get-AzSubscription

# From list of subscriptions create an array of subscription IDs
$AZURE_SUBSCRIPTIONS = @()
$AZURE_SUBSCRIPTIONS = @('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx')

# Assign reader scope

$AZURE_SUBSCRIPTIONS | % {
  New-AzRoleAssignment -Scope ('/subscriptions/{0}' -f $_) `
    -ApplicationId $AZURE_POC_SP.ClientId `
    -RoleDefinitionName Reader
}

# Sample output
RoleAssignmentId   : /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/providers/Microsoft.Authorization/roleAssignmen
                     ts/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
Scope              : /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
DisplayName        : <% APPLICATION_NAME %>
SignInName         :
RoleDefinitionName : Reader
RoleDefinitionId   : bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
ObjectId           : zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz
ObjectType         : ServicePrincipal
CanDelegate        : False
```

## Deprovisioing Role and Service Principal After POC

```powershell
# Removing ServicePrincipal
$AZURE_SAAS_SOLUTION = '<% APPLICATION_NAME %>'
Remove-AzADServicePrincipal -ApplicationId $(Get-AzADServicePrincipal -DisplayName $AZURE_SAAS_SOLUTION).ApplicationId

```