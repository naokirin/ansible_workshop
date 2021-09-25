# Ansible Workshop

このリポジトリは、Ansible初心者向けに演習用として作成したものです。

各ディレクトリのREADMEに従って、ステップを踏んでAnsibleの演習ができるようになっています。  
なお、演習では、Amazon Linux 2 向けに実行することを想定しています。  

ただし、以下についての知識があることを前提とします。

* LinuxのCUI環境で基本的なファイル操作、ユーザー作成およびパッケージのインストールができる
* SSH接続できるサーバーにSSH接続するための手順、方法がわかる

また、この演習では以下については行いません。

* Ansible自体のインストール方法

## 演習

演習の内容は以下となっています。

* Practice01: モジュールを使ってみる
* Practice02: ファイルの作成と編集をする
* Practice03: ロールを使ってみる
* Practice04: インベントリを編集してみる
* Practice05: 変数を利用してみる
* Practice06: 条件を利用してみる
* Practice07: Valutを利用してみる

### 準備

演習を始める前に、以下で必要な環境を準備しましょう。  
以下を実行すると、 `.keys` 以下に演習で利用するためのSSH鍵が生成されます。  

```sh
./prepare.sh
```

なお今回は演習のため、ssh鍵へのパスフレーズやsudo時のパスワードなどは不要としていますが、実際に利用する際には設定するようにしてください。  
その場合、 `ansible-playbook` コマンドに `--ask-pass` や `--ask-become-pass` をつけて実行してみてください。

### 以降について

以降では、Ansibleの一般的な情報をまとめています。  
必要な最低限の知識については、各演習でも記載しますので、熟読せずに演習から開始することもできます。

## バージョン

* Ansible 4.6.0
* Python 3.9

Dockerについては、基本的に最新バージョンであれば動くはずです。

## 公式ドキュメント

Ansibleの詳細については、公式のドキュメントを参照してください。

* [Ansible Documentation](https://docs.ansible.com/)
* [Ansible User Guide](https://docs.ansible.com/ansible/latest/user_guide/index.html)


利用できるモジュールとプラグインの全てのリストについては以下を参照してください。

* [Ansible Collection Index](https://docs.ansible.com/ansible/latest/collections/index.html)

多くのモジュールがあり、困惑したかもしれませんが、個々の演習では基本的に利用するモジュールを指定します。  
Ansible初心者の方は、基本的なプラグインとモジュールを含む[ansible.builtin](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html) から見ることをお勧めします。

## Ansibleの基本概念

Ansibleは、オープンソースの構成管理ツールです。  
あらかじめ準備した設定ファイルに従って、パッケージのインストールや設定などを自動的に実行することができます。  
また、オーケストレーションやデプロイメント機能も持っています。

Ansibleは、以下のような特徴を持ちます。

* エージェントレス: 構成管理の対象になるサーバーに専用のエージェントなどを必要としない
* YAMLによる記述:  Playbookなどの処理手順は、YAMLフォーマットにより記述する
* モジュール:      様々な処理を提供された多くのモジュールを利用して行える
* 冪等性:         多くのモジュールで冪等性（複数回実行しても同じ状態になる性質）が担保されている

### Ansibleの基本要素

Ansibleによる構成管理の設定は、以下の基本的な要素で構成されています。

* Playbook:  実際に実行する手順を記載したファイル（YAMLファイル）
* Role:      手順をグループ化して、再利用可能にする（規定のディレクトリ構成で作成）
* Inventory: 対象のホストを定義するファイル（INI形式のファイル）
* Module:    提供されている利用可能な処理の最小単位
* Plugin：   提供されているAnsibleの機能を拡張する機能
* Task:      PlaybookもしくはRoleで、モジュールを利用して実行する個々の処理

## Ansible Vault （機密情報の管理）

Ansibleで構成管理をすることで、構築手順を実行可能なファイル郡としてリポジトリ管理したりすることができます。  

**ただし、機密情報をリポジトリに入れるべきではありません。**  

しかしながら、サーバーの構成に機密情報は不可分である場合も多々あります。  
そこでAnsibleでは、Ansible Vaultという機能でファイルを暗号化しておき、実行時に復号化させることができます。

[Ansible Vault Documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html)

## Ansible Galaxy （シェアされたRoleの利用）

Ansibleを書いていると、非常に複雑な構築手順を必要とするパッケージのインストールなどの、いちから書くには非常に手間がかかるものも多くあります。

そういった場合、Ansible Galaxyを利用して、シェアされたRoleを取得して利用することが可能です。

[Ansible Galaxy Documentation](https://galaxy.ansible.com/docs/)

## Ansible Lint (Lintツール)

Ansibleをチームで利用する際や、大規模化していくと、Ansibleで記載した内容を適切に保つことが難しくなる場合があります。

そこで Ansbleには、Lintツールが提供されています。  
個別のインストールが必要ですが、静的に記述を分析することができます。

[Ansible Lint Documentation](https://ansible-lint.readthedocs.io/en/latest/)

## LICENSE

このリポジトリは、[MIT License](https://github.com/naokirin/ansible_workshop/blob/master/LICENSE)のもとで公開されています。