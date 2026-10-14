{ pkgs, ... }:

/* WiVRn: streams OpenXR from this machine to the HTC Vive XR Elite over the LAN.
   WayVR starts when the headset connects and puts the desktop into VR.

   The headset app must be the same WiVRn version as the server; install it with
   the wizard in `wivrn-dashboard`. WiVRn lists the XR Elite as supported but laggy.

   Bitrate, resolution scale and foveation are not server options in this WiVRn
   (26.6.2): set them in the WiVRn app on the headset. The server picks VA-API on
   this AMD card and the best codec both sides support by itself. */
{
  services.wivrn = {
    enable = true;
    openFirewall = true;     # 9757/tcp+udp; Avahi opens 5353/udp itself
    autoStart = true;        # user service, started at login
    highPriority = true;     # CAP_SYS_NICE for async reprojection

    config = {
      enable = true;
      json.application = [ pkgs.wayvr ];
    };
  };
}
