
## Setting up GBC dev prerequisites

Setting the development environment can be tricky because the default versions for
for most of the tools are too old on most LTS ( Long term support ) type distributions.

### CentOS 7 ( and probably 6 )

```bash
sudo yum remove nodejs
sudo curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
sudo yum install -y unzip git nodejs
sudo npm install -g grunt-cli
```

### Debian

```bash
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y unzip git nodejs
sudo npm install -g grunt-cli
```

## Setting the GBC project

Download from the 4js.com web site the latest project file and extract it to a clean folder

```bash
$ mkdir gbc_project
$ cd gbc_project
$ unzip ~/Downloads/fjs-gbc-1.00.48-build201810051640-project.zip
$ cd gbc-1.00.48
$ npm install
$ grunt
```
