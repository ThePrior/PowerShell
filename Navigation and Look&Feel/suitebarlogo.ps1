$webapp = get-spwebapplication -identity "http://prdspace.awp.nhs.uk"
$webapp.SuiteNavBrandingLogoUrl = "http://prdspace.awp.nhs.uk/SiteCollectionImages/ourspace-icon.png "
$webapp.SuiteNavBrandingLogoTitle ="Ourspace"
$webapp.SuiteNavBrandingLogoNavigationUrl = "http://Ourspace"
$webapp.Update()
