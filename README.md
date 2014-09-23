* Greap
=====

This is a repository to host Greap (vanilla), a project using the LeapMotion device.
To use, you need to download a latest stable version of SuperCollider, and GECO.
GECO is used to map out the Leap's data into SuperCollider. At the time of development of Greap GECO didn't support OSC, currently the software is using MIDI protocol.

Gr(ain) + (L)eap = Greap. /Greap/ is an interactive music environment made to create live electroacoustic music. It started as a research project to investigate the gestural manipulation of sound events, and explore the affordances of open air interfaces. The idea was originally conceived by the need to shape sounds using hands.

Usage
- Download the zip folder or clone Greap on your computer.
- Download SC from here:http://supercollider.sourceforge.net/
- GECO: https://airspace.leapmotion.com/

Run
- Move Beerffers file to Extensions folder of SuperCollider found in Application Support folder.
- Place any sound files (mono) you want to use at the folder inside GreapCode folder Greap/GreapCode/Sounds.
- Open Greap.scd in SuperCollider and execute the whole file (this should open GECO and run the GECOMapper file automatically).

TODO
- Make GECO and SC communicate via OSC protocol (as of now GECO supports OSC).
