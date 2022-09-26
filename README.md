# Apex Starter Pack

If you were to be dropped into a new Salesforce project tomorrow, what tools would you want to have at your ready? What would you need to hit the ground running?

`apex-starter-pack` is my answer to that question. This repository contains a suite of utilities and applications designed to kick-start your Salesforce project. The end goal is to reduce time spent developing internal tools, and maximize time spent solving actual business problems.

This repository includes the following libraries:

-   [ApexUtils](force-app/main/default/classes/ApexUtils): A collection of utility classes designed to make your life easier.
-   [DatabaseLayer](force-app/main/default/classes/DatabaseLayer): A DML & SOQL mocking framework.
-   [GarbageCollection](force-app/main/default/classes/GarbageCollection): A framework for automatically handling stale data.
-   [Logger](force-app/main/default/classes/Logger): A simple logging framework that gives targeted visibility into complex processes.
-   [Rollup](force-app/main/default/classes/Rollup): Create custom rollup operations via Apex or Flow.
-   [TriggerHandler](force-app/main/default/classes/TriggerHandler): A basic Trigger Handler with utility methods to make trigger operations a breeze.

## Installation

### **For General Use**

`apex-starter-pack` is available as an unlocked package. Click the appropriate link below to install the latest version:

<p>
    <a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04t8b000001RvnrAAC">
        <img 
            alt="Deploy to Salesforce (Production/Developer Edition)" 
            src="media/prod-deploy.png" 
            width="20%"
        >
    </a>    
    &emsp;
    <a href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04t8b000001RvnrAAC">
    <img 
        alt="Deploy to Salesforce (Sandbox)" 
        src="media/sb-deploy.png" 
        width="20%"
        >
    </a>
</p>

### **For Development**

When contributing to `apex-starter-pack`, follow these steps:

1. Sign in to a Salesforce [Dev Hub](https://developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/dev_hub_intro.htm).
    - If you don't have access to a DevHub, create a free [Developer Edition](https://developer.salesforce.com/signup) org. Once created, follow the steps to [enable DevHub features](https://developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/sfdx_setup_enable_devhub.htm).
2. Create a [new scratch org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_create.htm):

```
sfdx force:org:create -f config/project-scratch-def.json -w 60 --durationdays 30 --setdefaultusername --json --loglevel fatal --setalias {YOUR_ALIAS_HERE}
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
