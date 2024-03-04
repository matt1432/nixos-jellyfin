{cfg, lib,  ...}:
/*
xml
*/
''
  <?xml version="1.0" encoding="utf-8"?>
  <BrandingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <LoginDisclaimer>${cfg.loginDisclaimer}</LoginDisclaimer>
    <CustomCss>${cfg.customCss}</CustomCss>
    <SplashscreenEnabled>${lib.boolToString cfg.splashscreenEnabled}</SplashscreenEnabled>
  </BrandingOptions>
''
