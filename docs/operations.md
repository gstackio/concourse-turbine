Operations
==========


Backup
------

In order to back Concourse ATC database along with Credhub and UAA databases,
run the folowwiing `bbr` command.

    bbr deployment --deployment "concourse" backup --with-manifest


The `bbr` CLI can be installed with `brew install cloudfoundry/tap/bbr`.


Cleanup stalled workers
-----------------------

You should regularily check for stalled workkers like this.

    fly -t "gk-plat-devs" workers

Run the following `fly` command.

    fly -t "gk-plat-devs" workers \
        | grep --color="never" -F "stalled" \
        | awk '{print $1}' \
        | xargs -n1 fly -t "gk-plat-devs" prune-worker -w
