Concourse Turbine
=================

This repository deploys a Concourse cluster behind a Træfik reverse-proxy.

It is a distribution for infrastructure-as-code declarative description of a
production-ready Concourse cluster, based on the _Turbine Framework_ and the
[Turbine CLI][turbine_cli].

Historically, this project is related to the former
[Concourse GBE Downstream][concourse_gbeds], which is now deprecated. The
main difference is that this Turbine project does not rely on any upstream
distribution and is rather a standalone distribution instead, which simplifies
its usage.

[turbine_cli]: https://github.com/gstackio/turbine-cli
[concourse_gbeds]: https://github.com/gstackio/concourse-gbeds



Topology & Architecture
-----------------------

The Concourse Cluster from Easy Foundry has these charateristics:

- CredHub for storing pipeline secrets

- UAA for CredHub (not for autenticating users, contributions are welcome)

- Separate instance groups for CredHub and UAA (allows independent scaling of
  those components)

- Security: encryption all over the place
    - Encryption of data a the database level
    - HTTPS between all components
    - No HTTP anywhere

- Discovery (and failover) of components through BOSH DNS aliases (the current
  best practice, and most portable choice)

- Sanity tests as post-deploy hook (this fixes a missing piece, because no
  smoke tests are shipped by the Concourse BOSH Release, unfortunately)

- Scale horizontally for limited downtime during upgrades

    - Scale ATC (the web UI), CredHub, UAA and Concourse Worker to 2
      instances, for limited downtime when upgrading the Concourse cluster

    - Keep Postgres to 1 instance (because the standard and basic
      [Postgres BOSH Release][postgres_release] we use doesn't implement
      leader-follower replication, nor failover, which BTW are not trivial
      matters)

- Add the ATCs behind a [Træfik][traefik_release] reverse-proxy

    - With [circuit breaking][traefik_circuit_breaking]: whenever those 2 ATCs
      produce more than 50% network errors, then a “Service Unavailable” error
      message is displayed by Træfik

    - With [Dynamic Round Robin load-balancing][traefik_drr_lb] between ATC
      nodes, in case only one of them performs bad compared to the other

    - With [health checks][traefik_health_check], so that when an ATC node is
      shut down by BOSH during an upgrade, then no traffik is served to it
      anymore

- Support BBR backups

- Have inetrnal traffic between components not go through the front
  reverse-proxy and use BOSH DNS load-balancing instead

    - Have Credhub and UAA be reachable on ports 443

    - Resolve external fully-qualified DNS names to private cluster IPs
      internally, using BOSH DNS

[postgres_release]: https://github.com/cloudfoundry/postgres-release
[traefik_release]: https://github.com/gstackio/traefik-boshrelease
[traefik_circuit_breaking]: https://docs.traefik.io/basics/#circuit-breakers
[traefik_drr_lb]: https://docs.traefik.io/basics/#load-balancing
[traefik_health_check]: https://docs.traefik.io/basics/#health-check



Quick Start
-----------

Prerequisites:
- Direnv should be installed. Follow instructions from [direnv.net][direnv].
- VirtualBox v5.2 should be installed. Contributions are welcome for
  supporting newer versions. We are using [this Ansible Role][vbox52role] for
  that.

```bash
git clone https://github.com/gstackio/concourse-turbine.git
cd concourse-turbine
direnv allow
git clone https://github.com/gstackio/turbine-cli.git .cache/turbine-cli
vim ddbox-bosh-env/conf/spec.yml   # edit value for 'external_ip:'
vim ddbox-garden-env/conf/spec.yml # edit value for 'external_ip:'
TURBINE_ENVIRONMENT=ddbox-garden-env infra up
TURBINE_ENVIRONMENT=ddbox-bosh-env infra up
```

[direnv]: https://direnv.net/
[vbox52role]: https://github.com/gstackio/gstack-bosh-environment/tree/master/ddbox-standalone-bosh-env/provision/roles/virtualbox



Upgrading
---------

```bash
git pull
TURBINE_ENVIRONMENT=ddbox-garden-env infra up
TURBINE_ENVIRONMENT=ddbox-bosh-env   infra up
infra recover -y traefik concourse harbor
infra converge --dry-run traefik
infra converge -y concourse harbor traefik
```



Housekeeping
------------

Pruning stale workers is required once in a while.

```bash
fly -t gk-plat-ops workers | tail +3 | cut -d" " -f1 | xargs -n1 fly -t gk-plat-ops prune-worker -w
```



Contributing
------------

Please feel free to submit issues and pull requests.



Author and License
------------------

Copyright © 2018-2021, Benjamin Gandon, Gstack

Like BOSH and Turbine, this Turbine distrib is released under the terms of the
[Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0).

<!--
# Local Variables:
# indent-tabs-mode: nil
# End:
-->
