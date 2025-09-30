Create subdirectories for each category you want to call videos from HA for.

Multiple videos can be placed in a single directory, and the code will randomly pick one from the available videos.

For instance having a subdirectory of "Doorbell" and then placing videos in this, any time your Doorbell automation is triggered, 
it will play one of those videos from the Doorbell subdirectory.

The path to $HOME/Videos/ is hard coded, the subdirectory comes from the argument passed to the REST server.
