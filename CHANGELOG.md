# Changelog for vagrant-openstack-plugin

## 0.3.1 (April 14, 2014)
- Adds the ability to create security groups
- Allows vagrant status to query the openstack api to determine what is up

## 0.3.0 (September 25, 2013)

- Adds support to determine IP address to use
- Region Support
- Enabled controlling multiple VMs in parallel
- Honor disabling of synced folders
- Adds `availability_zone` option to specify instance zone
- Added --delete to rsync command
- Call SetHostname action from Vagrant core in up phase
- Handled not having the box and providing it via a box_url.
- Allowed vagrant ssh -c 'command'
- Adds tenant to network request
- Improved documentation

## 0.2.2  (May 30, 2013)

- Also ignore HOSTUNREACH errors when first trying to connect to newly created VM

## 0.2.1 (May 29, 2013)

- Fix passing user data to server on create
- Floating IP Capability
- Added ability to configure scheduler hints
- Update doc (network config in fact has higher precedence than address_id)
- 'address_id' now defaults to 'public', to reduce number of cases in read_ssh_info
- Introduced 'address_id' config, which has a higher order of precedence than 'network'

## 0.2.0 (May 2, 2013)

- Added docs
- Removed metadata validation and bumped version
- Tenant and security groups are now configurable

## 0.1.3 (April 26, 2013)

- Added the ability to pass metadata keypairs to instances
- Added support for nics configurations to allow for selection of a specific network on creation

## 0.1.2 (April 26, 2013)

- Added the option of passing user data to VMs
- Enabled `vagrant provision` in this provider
- Made finding IP address more stable
- Doc improvements and minor fixes

## 0.1.0 (March 14, 2013)

- Initial release
