let
  variables = import ./../../../variables.nix;
  colors = variables.colors.active;
in
{
  # Thunar configuration
  programs.xfce.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  # Thunar preferences
  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/thunar.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="thunar" version="1.0">
      <property name="last-view" type="string" value="ThunarDetailsView"/>
      <property name="last-icon-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_100_PERCENT"/>
      <property name="last-window-width" type="int" value="1000"/>
      <property name="last-window-height" type="int" value="600"/>
      <property name="last-window-maximized" type="bool" value="false"/>
      <property name="last-details-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_38_PERCENT"/>
      <property name="last-details-view-column-widths" type="string" value="50,150,50,50,430,50,50,71,50,154"/>
      <property name="last-separator-position" type="int" value="170"/>
      <property name="last-show-hidden" type="bool" value="true"/>
      <property name="last-details-view-visible-columns" type="string" value="THUNAR_COLUMN_DATE_MODIFIED,THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_TYPE"/>
      <property name="misc-date-style" type="string" value="THUNAR_DATE_STYLE_SIMPLE"/>
      <property name="misc-folders-first" type="bool" value="true"/>
      <property name="misc-text-beside-icons" type="bool" value="false"/>
      <property name="shortcuts-icon-emblems" type="bool" value="true"/>
      <property name="shortcuts-icon-size" type="string" value="THUNAR_ICON_SIZE_24"/>
      <property name="tree-icon-size" type="string" value="THUNAR_ICON_SIZE_16"/>
    </channel>
  '';

  # Thunar theme integration (GTK)
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };
}
