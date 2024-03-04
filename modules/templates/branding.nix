{
  cfg,
  mkBool,
  mkEmptyDefault,
  ...
}:
/*
xml
*/
''
  <?xml version="1.0" encoding="utf-8"?>
  <BrandingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    ${mkEmptyDefault cfg.loginDisclaimer "LoginDisclaimer"}
    ${mkEmptyDefault cfg.customCss "CustomCss"}
    ${mkBool cfg.splashscreenEnabled "SplashscreenEnabled"}
  </BrandingOptions>
''
