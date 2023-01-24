# Apex Starter Pack

If you were to be dropped into a new Salesforce project tomorrow, what tools would you want to have at your ready? What would you need to hit the ground running?

`apex-starter-pack` is my answer to that question. This repository contains a suite of utilities and applications designed to kick-start your Salesforce project. The end goal is to reduce time spent developing internal tools, and maximize time spent solving actual business problems.

This repository is available as an unlocked package. Because the package is designed to be used as a base library for other projects, most of its classes and methods are `global`. Simply refer to components by their namespace (`apxsp`).

## Installation

### **For General Use**

`apex-starter-pack` is available as an unlocked package. See [Releases](https://github.com/jasonsiders/apex-starter-pack/releases) for the latest install link.

### **For Development**

When contributing to `apex-starter-pack`, follow these steps:

1. Sign in to a Salesforce [Dev Hub](https://developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/dev_hub_intro.htm).
    - If you don't have access to a DevHub, create a free [Developer Edition](https://developer.salesforce.com/signup) org. Once created, follow the steps to [enable DevHub features](https://developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/sfdx_setup_enable_devhub.htm).
2. Create a [new scratch org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_create.htm):

```
sfdx force:org:create -f config/project-scratch-def.json -w 60 --durationdays 30 --loglevel fatal --json --nonamespace --setdefaultusername --setalias {YOUR_ALIAS_HERE}
```

3. Run these commands to clone this repo, create a new branch, and push the code to your scratch org:

```
git clone https://github.com/jasonsiders/apex-starter-pack.git
git checkout -b {YOUR_BRANCH_NAME}
sfdx force:source:push
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## License

See [LICENSE.md](LICENSE.md) for more details.
