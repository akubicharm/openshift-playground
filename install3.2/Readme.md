# OpenShift 3.2 Install Scripts

## 目的
Vagrant で起動した仮想環境に、OpenShift 3.2 をインストールします。
Vagrant の box イメージは、Docker Storage Pool の設定もされている CDK のイメージを利用します。
Red Hat Enterprise Linux 7.2 のbox イメージのダウンロードはこちら。 https://access.redhat.com/downloads/content/293/ver=2/rhel---7/2.0.0/x86_64/product-software

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
DNSはホストOSの設定を引き継げるように virtualbox.customize にて natdnshostresolver1 を有効しします。
```
      virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
```

### 仮想OSの起動
`vagrant up` コマンドで、仮想OSを起動します。 起動直後、VirtualBoxのGuestAdditionが使えない状態になっていますので、Development Tools と kernel-devel パッケージをインストールします。

```
sudo yum -y groupinstall 'Development Tools'
sudo yum -y install kernel-devel
```

これらの処理は、`vagrant-provision.sh` を利用することも可能です。
```
vagrant-provision.sh master
vagrant-provision.sh node
```

### OpenShift のインストール
