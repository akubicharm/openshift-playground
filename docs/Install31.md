# はじめに

## 参考資料
https://access.redhat.com/documentation/en/openshift-enterprise/3.1/installation-and-configuration/installation-and-configuration


## インストール作業で必要な前提知識
* subscription-manager
* yum
* git
* ansible
* systemd


## インストールする構成
* ose3-master.example.com 192.168.1.110
* ose3-node01.example.com  192.168.1.111
* ose3-node02.example.com  192.168.1.112

![サーバ構成](images/v3.1ServerStructure.png)

※インストールガイドでは、Master サーバをインフラ用 Node としても利用しています。

このインストール手順書では、 Quick Install を利用して インストールすることを前提としています。
この方式でインストールした場合、ユーザ認証は設定されませんので、後から設定します。
認証方式の変更は https://access.redhat.com/documentation/en/openshift-enterprise/3.1/installation-and-configuration/chapter-5-configuring-authentication を参照してください。


## OS インストール
OpenShift 3 のインストールには Red Hat Enterprise Linux 7.1 以上が必要です。
Vagrantのboxイメージが https://access.redhat.com/downloads/content/293/ver=2/rhel---7/2.0.0/x86_64/product-software から取得できるので、これを利用すると論理ボリュームの設定がすでにされたイメージが使えるので、便利です。

注意：
Red Hat Container Development Kit の box イメージは、kubernetes のパッケージがインストール済みであるため、OpenShift のクイックインストールが失敗します。
最初に、kubernetes-client, kubernetes-master, kubernetes-node, kubernetes パッケージを削除してください。

---
# 公開鍵の設定
インストールを実行するユーザで公開鍵を作成します。
* 実行ユーザ: vagrant
* 実行サーバ: Master サーバ

以降の作業をマスターサーバから ssh で実行するために、先に、公開鍵を配布します。

##  公開鍵の作成

    [vagrant@master ~]# ssh-keygen
    Generating public/private rsa key pair.
    Enter file in which to save the key (/home/vagrant/.ssh/id_rsa):  ← リターンを入力
    Created directory '/home/vagrant/.ssh'.
    Enter passphrase (empty for no passphrase):  ← リターンを入力
    Enter same passphrase again:  ←  リターンを入力
    Your identification has been saved in /home/vagrant/.ssh/id_rsa.
    Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub.
    The key fingerprint is:
    72:7e:9c:61:7a:f1:af:f5:c6:ad:7d:c0:b9:c7:77:a3 vagrant@master
    The key's randomart image is:
    +--[ RSA 2048]----+
    |                 |
    |                 |
    |                 |
    |                 |
    |      . S +  . . |
    |       + + =  +  |
    |        o = . .=.|
    |         o   o.+X|
    |            .E++B|
    +-----------------+


## 公開鍵の配布
    [vagrant@master ~]# for host in ose3-master.example.com \
     ose3-node01.example.com \
     ose3-node02.example.com; \
    do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; \
     done

---
# 必要なRPMパッケージのインストール

インストール対象の全てのサーバで実施します。


## 環境確認
* github との接続

 インストール中に、ImageStream（OpenShiftで利用できるアプリケーションテンプレート）の取得の過程で github.com に接続しますので、マスタサーバから github.com へ接続可能であることを確認してください。

* hosts ファイル

 名前解決するため、マスタサーバ、ノードサーバの /etc/hosts の設定を確認してください

## Subscriptionの有効化

* 実行ユーザ: vagrant
* 実行サーバ: Master、Node 全て

    [vagrant@xxx ~]# sudo subscription-manager attach --pool $RHN_POOLID
    [vagrant@xxx ~]# sudo subscription-manager repos --disable="*";
    [vagrant@xxx ~]# sudo subscription-manager repos \
    --enable=rhel-7-server-rpms \
    --enable=rhel-7-server-extras-rpms \
    --enable=rhel-7-server-optional-rpms \
    --enable=rhel-7-server-ose-3.1-rpms;" \
    done


## パッケージのインストール
* 実行ユーザ：vaagrant
* 実行サーバ：Master、Node 全て

## 必要なパッケージのインストールとアップデート
    [vagrant@xxx ~]# sudo yum install -y wget git net-tools bind-utils iptables-services bridge-utils bash-completion;
    [vagrant@xxx ~]# sudo yum update -y;

## OpenShift のパッケージインストール
    [vagrant@xxx ~]# sudo yum install -y atomic-openshift-utils

---
# Docker のインストール
* 実行ユーザ: vagrant
* 実行サーバ: Master, Node

## docker パッケージインストール
    [vagrant@xxx~]# sudo yum install docker

## /etc/sysconfig/docker の編集
OPTIONSプロパティで、`insecure-registory` として利用できるサブネットを指定

File = /etc/sysconfig/docker

    OPTIONS=--selinux-enabled --insecure-registry 172.30.0.0/16

## doker の再起動
    [root@master ~]# systemctl restart docker


## docker のステータス確認
    [root@master ~]# systemctl status docker
    docker.service - Docker Application Container Engine
       Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled)
       Active: active (running) since 木 2015-07-02 21:03:20 JST; 1h 26min ago
         Docs: http://docs.docker.com
     Main PID: 1152 (docker)
       CGroup: /system.slice/docker.service
               └─1152 /usr/bin/docker -d --selinux-enabled --insecure-registry 172.30.0.0/16 --add-registry registry.access.redhat.com


## DockerStorageの設定
検証環境の構築では、必須ではないのでここでは割愛します。
Docker Storageの設定をする場合は、マニュアルを参照してください。
Red Hat Container Development KitのVagrantイメージを利用している場合は、すでに設定されています。


---
# OpenShiftのインストール(RPM)

## インストール設定ファイルの作成
インストールを実行するユーザのホームディレクトリの配下にインストール設定用のファイルを準備しておくと、簡単にインストールができます。
v3.1.1 からは、`atomic-openshift-master`, `atomic-openshift-node` をコンテナで実行することも可能になりましたが、ここでは従来のrpmでインストールするため、`containerized: false`  とします。

    [~/.config/openshift/installer.cfg.yml]
    version: v1 
    variant: openshift-enterprise
    variant_version: 3.1
    ansible_ssh_user: vagrant
    ansible_log_path: /tmp/ansible.log
    hosts:
    - ip: 192.168.1.110
      hostname: ose3-master.example.com
      public_ip: 192.168.1.110
      public_hostname: ose3-master.example.com
      master: true
      node: true
      containerized: false
      connect_to: 192.168.1.110
    - ip: 192.168.1.111
      hostname: ose3-node01.example.com
      public_ip: 192.168.1.111
      public_hostname: ose3-node01.example.com
      node: true
      connect_to: 192.168.1.111
    - ip: 192.168.1.112
      hostname: ose3-node02.example.com
      public_ip: 192.168.1.112
      public_hostname: ose3-node02.example.com
      node: true
      connect_to: 192.168.1.112


## インストーラの実行
    [vagrant@master ~]# atomic-openshift-installer -u install


インストールが終わると、`.config/openshift/installer.cfg.yml`にインストーラが生成したAnsibleのコンフィグファイルの保存場所が`ansible_config`という属性で追記されています。


## ノードの確認
    [vagrant@master ~]# oc get nodes
    NAME                LABELS                                                   STATUS                     AGE
    ose3-master.example.com  kubernetes.io/hostname=ose3-master.example.com                Ready,SchedulingDisabled   10h
    node01.example.com  kubernetes.io/hostname=node01.example.com                Ready                      10h
    node02.example.com  kubernetes.io/hostname=node02.example.com                Ready                      10h


## ラベルの付与
Node にラベルが付いていない場合は、ラベルを付与します。

|ノード|ラベル|
|---|---|
|master|region=infra,zone=default|
|node01|region=primary,zone=east|
|node02|region=primary,zone=west|


各ノードにラベルが付与されていない場合は、ラベルを付与します。
    [vagrant@master ~]$ oc label node ose3-master.example region=infra zone=default
    [vagrant@master ~]$ oc label node ose3-node01.example.com region=primary zone=east
    [vagrant@master ~]$ oc label node ose3-node02.example.com region=primary zone=west

    [vagrant@master ~]$ oc get nodes
    NAME                    LABELS                                                                   STATUS                     AGE
    ose3-master.example.com   kubernetes.io/hostname=ose3-master.example.com,region=infra,zone=default   Ready,SchedulingDisabled   2h
    ose3-node01.example.com   kubernetes.io/hostname=ose3-node01.example.com,region=primary,zone=east    Ready                      19m
    ose3-node02.example.com   kubernetes.io/hostname=ose3-node02.example.com,region=primary,zone=west    Ready                      19m    



## 確認
ここまでで、OpenShiftのインストールが完了しました。https://ose3-master.example.com:8443 にアクセスできるか確認してみましょう。


---
# インストール後の設定

## ユーザ認証方式の変更
クイックインストールの場合は、ユーザ認証方式が設定されず deny_all になっているので、誰も使えません。HTPasswd認証ができるように変更します。

### httpd-tool のインストール
    [vagrant@master]# sudo yum install -y httpd-tools


### パスワードファイルの作成
    [vagrant@master]# sudo touch /etc/origin/openshift-passwd


### ユーザ登録
    [vagrant@master]# sudo htpasswd -b /etc/origin/openshift-passwd joe redhat


変更前

    oauthConfig:
      assetPublicURL: https://ose3-master.example.com:8443/console/
      grantConfig:
        method: auto
      identityProviders:
      - name: deny_all
        challenge: True
        login: True
        provider:
          apiVersion: v1
          kind: DenyAllPasswordIdentityProvider

変更後

    oauthConfig:
      assetPublicURL: https://ose3-master.example.com:8443/console/
      grantConfig:
        method: auto
      identityProviders:
      - name: htpasswd_auth  ←ここを編集
        challenge: True
        login: True
        provider:
          apiVersion: v1
          kind: HTPasswdPasswordIdentityProvider  ←ここを編集
          file: /etc/origin/openshift-passwd      ←ここを追加

## DNS設定
Master サーバでは、内部的に利用するべつのDNSサーバが稼働しています。OpenShiftにデプロイしたアプリケーションの名前解決ように、別途、ネーミングサービスを起動する場合は、Master サーバ以外で実行してください。
## 参考
https://github.com/openshift/training/blob/master/beta-4-setup.md#appendix---dnsmasq-setup


## Docker RegistryとRouterの作成
STIビルドなどで作成した Docker Image を保持するためのDocker Registoryとルーティング機能を提供するHAProxyのデプロイします。

* 実行ユーザ: vagrant
* 実行サーバ: Master


### スケジューリングの有効化
インストール直後は、masterサーバはスケジューリング不可（Podのデプロイ不可）になっているので、スケジューリング可能にします。

    [vagrant@master ~]# oadm manage-node master --schedulable=true


### security context constraint(SCC)の確認
OpenShift内部でDocker Imageを保持するレジストリと、アプリケーションの名前解決をするためのルーティング用のSCCがあることを確認します。
    [vagrant@master ~]# oc export scc privileged
    users:
    - system:serviceaccount:default:registry
    - system:serviceaccount:default:router
  

### registry 作成
ここでは、Persistent Volume を使わずにマスターサーバのディレクトリをマウントする方式をとります。
Persistent Volume を利用する場合は、https://access.redhat.com/documentation/en/openshift-enterprise/3.1/installation-and-configuration/chapter-2-installing を参照してください。
Registoryがインフラ用ノードにデプロイされるように、　`--selector="region=infra"` と指定します。

    [vagrant@master ~]# sudo mkdir -p /registry
    [vagrant@master ~]# sudo chmod 777 /registry
    [vagrant@master ~]# sudo oadm registry \
    --service-account=registry \
    --config=/etc/origin/master/admin.kubeconfig \
    --credentials=/etc/origin/master/openshift-registry.kubeconfig \ 
    --images='registry.access.redhat.com/openshift3/ose-${component}:${version}'  \
    --mount-host=/registry \
    --selector="region=infra" \ 
    --replicas=1 

Podのステータスが Running になっていることを確認します。

    [vagrant@master ~]$ oc get pods
    NAME                      READY     STATUS    RESTARTS   AGE
    docker-registry-1-1xpqk   1/1       Running   0          25s


### Router の作成
    [vagrant@master ~]# sudo oadm router --dry-run \
    --credentials=/etc/origin/master/openshift-router.kubeconfig \
    --service-account=router

    [vagrant@master ~]# sudo oadm router \
    --credentials=/etc/origin/master/openshift-router.kubeconfig \
    --service-account=router \
    --selector="region=infra" \
    --config=/etc/origin/master/admin.kubeconfig \
    --images='registry.access.redhat.com/openshift3/ose-${component}:${version}' \
    --replicas=1

PodのステータスがRunningになっていることを確認します。

    [vagrant@master ~]$ oc get pods
    NAME                      READY     STATUS    RESTARTS   AGE
    docker-registry-1-1xpqk   1/1       Running   0          13m
    router-1-638dq            1/1       Running   0          3m


### アプリケーションドメインのデフォルト値変更
アプリケーションのドメイン名の接尾辞が apps.example.com となるように変更します。

[/etc/origin/master/master-config.yaml]

変更前

    routingConfig:
      subdomain:  ""

変更前

    routingConfig:
    subdomain:  "apps.example.com"


### 利用者の追加
    [vagrant@master ~]# htpasswd -b /etc/origin/openshift-htpasswd joe redhat


