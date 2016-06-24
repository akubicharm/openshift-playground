# OpenShift 3.2 Install Scripts

## 目的
Vagrant のboxイメージを使った仮想環境に、OpenShift 3.2 をインストールします。
Vagrant の box イメージは、Docker Storage Pool の設定もされている CDK のイメージを利用します。
Red Hat Enterprise Linux 7.2 のbox イメージのダウンロードはこちら。 https://access.redhat.com/downloads/content/293/ver=2/rhel---7/2.0.0/x86_64/product-software

Product Variantで`Red Hat Container Development Kit (latest)`を選択してください。

### CDKを利用するためのサブスクリプション
Red Hat 製品を、開発者が個人利用を目的として利用できる Red Hat Developer Subscription を利用すると、CDKが利用できるようになります。 <https://www.redhat.com/ja/about/press-releases/rhjapan-red-hat-expands-red-hat-developer-program-no-cost-red-hat-enterprise-linux-developer-subscription>

### Red Hat Developer Subscription の利用登録
Red Hat Developers のサイト <http://developers.redhat.com/>で登録後、
カスタマポータル<https://access.redhat.com>から製品をダウンロードできるようになります。
30分くらいは時間かかるので、登録したらコーヒーでも飲んで一息ついてから、トライしてみてください。


## 構成
ラップトップでの利用を想定し、Master x 1 台、Node x 1 台の最小構成とします。
Hypervisor には Virtualbox を利用します。

## 環境構築手順

### Box の準備

```
vagrant box add <box ファイル名>
```

### Vagrant ファイルの編集
NAT と ホストオンリーネットワークを構成します。ホストオンリーネットワークのIPアドレスは適宜変更してください。

初回起動時は、auto_config: true とし、2回目以降は auto_config: false としてください。

```
    master.vm.network :private_network, ip: "192.168.32.11", auto_config: false
```


DNSはホストOSの設定を引き継げるように virtualbox.customize にて natdnshostresolver1 を有効しします。
```
      virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
```

### Subscription情報ファイルの作成
`vagrant-provision.sh`, `install.sh` で利用する Red Hat Networkのユーザー名、パスワード、プールIDをファイルに保存します。
* rhn-username : Red Hat Networkのユーザー名。例）ose@example.com
* rhn-password : Red Hat Networkのパスワード
* rhn-poolid : Red Hat NetworkのPoolID


### 仮想OSの起動
`vagrant up` コマンドで、仮想OSを起動します。 起動直後、VirtualBoxのGuestAdditionが使えない状態になっていますので、Development Tools と kernel-devel パッケージをインストールします。

```
sudo yum -y groupinstall 'Development Tools'
sudo yum -y install kernel-devel
```

これらの処理は、`vagrant-provision.sh` を利用することも可能です。
```
vagrant-provision.sh master
vagrant-provision.sh node01
```

### install.sh の編集
IPアドレスを変更した場合は、`install.sh`スクリプトでも利用しているIPアドレスを変更します。

### OpenShift のインストール


`install.sh` スクリプトを使ってOpenShiftをインストールします。
```
install.sh
```
インストールが終わったら、masterサーバへログインして、OpenShiftのNode, Router, Docker Registryの状態を確認しましょう。

```
oc get nodes
oc get pods
```

OpenShift3.2からは Docker RegistryのプロセスをUID=1001で実行するようになったので、Docker RegistryのPodを起動するNodeサーバのマウントポイントの権限を chown で変更しておく必要があります。
`install.sh`では、masterサーバをインフラNodeとしてきどうする想定になってるので、`master`サーバの/registryディレクトリの権限を変更しています。
```
chown 1001:root /registry
```

`master`サーバ以外でDocker RegistryのPodを実行する場合は、適切な仮想サーバでディレクトリのオーナーを変更します。

## ユーザ登録
インストール時にhtpasswdでの認証を利用するように設定しているので、htpasswdコマンドでユーザを追加します。
```
htpasswd -b /etc/origin/master/htpasswd <user> <password>
```
