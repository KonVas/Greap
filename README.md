Greap 1.0v
=====

This is Greap, a project using the LeapMotion device to shape sounds in real time. To use, you need to download a latest stable version of SuperCollider, and GECO. GECO is used to map out the Leap's data into SuperCollider. At the time of development of Greap GECO didn't support OSC, currently the software is using MIDI protocol.
Gr(ain) + (L)eap = Greap: is an interactive music environment made to create live electroacoustic music. It started as a research project to investigate the gestural manipulation of sound events, and explore the affordances of open air interfaces. The idea was originally conceived by the need to shape sounds using hands.

Some additional Info
- Greap uses the idea of scenes. Within this functionality one can store mapping, control values and audio sample information to use. In this version 5 scenes are implemented, but one is free to develop its own.

Usage
- Download SuperCollider: http://supercollider.sourceforge.net/
- GECO: https://airspace.leapmotion.com/

Run
- Move Beerffers.sc to Extensions folder of SuperCollider found in Application Support folder.
- Place any sound files (mono) you want to use at the folder inside GreapCode folder Greap/GreapCode/Sounds.
- Open Greap.scd in SuperCollider and execute the whole file (this should open GECO and run the GECOMapper file automatically).
- Once you have placed any sounds you want to use in Greap/GreapCode/Sounds folder go to 'scenes' and type the name of the sound to use. ~sounds[\nameOfSound] this will be the name of the sound that this scene will jump in and manipulate. The name of the sound must be the exact with the one in the folder without the extension, failing to do so the sound will be inaccesible.

TODO
- Make GECO and SC communicate via OSC protocol (as of now GECO supports OSC).
