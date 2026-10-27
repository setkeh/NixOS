{ pkgs, ... }:

/* WiVRn: streams OpenXR from this machine to the HTC Vive XR Elite over the LAN.
   WayVR starts when the headset connects and puts the desktop into VR.

   The headset app must be the same WiVRn version as the server; install it with
   the wizard in `wivrn-dashboard`. WiVRn lists the XR Elite as supported but laggy.

   Bitrate, resolution scale and foveation are not server options in this WiVRn
   (26.6.2): set them in the WiVRn app on the headset. The server picks VA-API on
   this AMD card and the best codec both sides support by itself. */
{
  imports = [ ./wayvr-physical-keyboard.nix ];

  services.wivrn = {
    enable = true;
    openFirewall = true;     # 9757/tcp+udp; Avahi opens 5353/udp itself
    autoStart = true;        # user service, started at login
    highPriority = true;     # CAP_SYS_NICE for async reprojection

    config = {
      enable = true;
      json = {
        application = [ pkgs.wayvr ];

        # Pin the encoder. VAAPI = the 7900 XTX's hardware encoder.
        # h265, not av1: the XR Elite can't decode AV1.
        encoder = {
          encoder = "vaapi";
          codec   = "h265";
          # Only needed if you have more than one GPU / render node:
          # device = "/dev/dri/renderD128";
        };

        # 10-bit HEVC. Test against 8 at your current headset bitrate.
        # If the green artifacts get WORSE, set this back to 8 first.
        "bit-depth" = 10;
      };
    };
  };

  /* adb, for the dashboard's headset-app installer. No udev rules needed:
     systemd 258+ gives the logged-in user access to ADB devices (uaccess).
     adb's default libusb backend does not list the XR Elite at all; its native
     Linux backend does, so make that the default. */
  environment.systemPackages = [ pkgs.android-tools ];
  environment.sessionVariables.ADB_LIBUSB = "0";
}
