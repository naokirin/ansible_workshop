# Practice01: モジュールを使ってみる

この演習ではシンプルに、モジュールを使ってサーバーで利用するユーザーを作成します。

## 01-1 Playbookを開く

さて、まずはPlaybookを開いてみましょう。

Playbookは、対象のサーバーに対して設定する内容を記述していくファイルになります。  
今回は事前に準備してあるため、そちらを開きます。

`server.yml` というファイルがあると思いますので、そちらをエディタで開いてください。  
拡張子の通りYAMLファイルのため、YAMLのシンタックスハイライトが利用できるエディタが望ましいです。

以下のようになっているでしょう。

```yaml
---
- hosts: web
  become: yes  # sudoで実行する
  tasks:
  - name: Create test_user
    # TODO: userモジュールを使ってtest_userユーザーを作成する
```

ファイルの中身を簡単に説明します。

`hosts: web` はこの処理をどのホストに対して実行するかを示しています。  
`become: yes` はsudoで実行することを指定するものです。
`tasks` 以下には、各処理手順を記載していきます（Roleを使う場合には記述が異なりますが、以降の演習で説明します）。

現在、 `tasks` 以下には1つ、 `name: Create test_user` があります。  
これはまだ実際の処理自体は記載されていません。  

## 01-2 userモジュールのドキュメントを見てみよう

TODOには、「userモジュールを使って」とあります。  

モジュールとは、Ansibleで提供される利用可能な処理の最小単位です。  
例えば、ユーザーを管理したり、ファイルを管理したり、パッケージを管理するなどの操作を提供してくれます。

今回はユーザーを作成するため、userモジュールを使用します。
userモジュールは、ansible.builtin名前空間にあるので、そこからドキュメント探してみましょう。  
https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html

説明とともに、Parameters でパラメータが記載されています。  
モジュールを利用する場合、ここから必要なパラメータを探して、指定していくことになります。

どのような書き方をするのかわからない人は、Parameters の下にある Examples を見てみましょう。

```yaml
- name: Add the user 'johnd' with a specific uid and a primary group of 'admin'
  ansible.builtin.user:
    name: johnd
    comment: John Doe
    uid: 1040
    group: admin

...
```

おそらく上記のような記載があると思います。  
このように、各モジュールには例も多くついているため、Parametersだけではわからない場合は、この例も参考にしてみましょう。

## 01-3 実際に書いてみる

ここまでで、PlaybookのTODOの部分を書く準備が整いました。  
今回は、以下を満たすようにユーザーを作成する設定を `server.yml` の `TODO` の部分に記載してください。

* ユーザー名は `test_user`
* ログインシェルは `/bin/bash`

※ 今回は入門ということでパスワードは指定しません  
※ またグループは別途グループの作成が必要になるため、今回は指定しないものとします

## 01-4 Playbookを実行してみる

それでは、実際にPlaybookを実行してみましょう。

今回はDockerコンテナ内から実行するため、Dockerコンテナに入って実行します。

Playbookは以下のようにして実行しましょう。

```sh
# practice01_use_module のディレクトリに移動します
cd ./practice01_use_module

# コンテナをビルドしておく
docker-compose build

# Ansibleを実行するコンテナと、管理対象にするコンテナを実行します
docker-compose up -d

# Ansibleを実行するコンテナに入ります
docker-compose exec control_node bash

# AnsibleでPlaybookを実行します
ansible-playbook server.yml -i hosts
```

うまく実行できたでしょうか？  
失敗した場合はエラーの内容を確認して、Playbookを修正してみましょう。  
成功した場合は一度Ansible実行用のコンテナから抜けて、管理対象のコンテナに入ってみましょう。

```sh
# exitコマンドでAnsible実行用のコンテナから抜ける
exit

# 管理対象のコンテナに入る
docker-compose exec managed_node bash

# ユーザーが作成されているか確認する
cat /etc/passwd | grep test_user
```

どうだったでしょうか？  
最後のコマンドで表示されれば、うまくユーザーが作成されているでしょう。

ここまでで、Practice01 は終わりになります。

最後にdockerコンテナを終了しておきましょう（以降の内容を実行する場合は、それらを実行後に行ってください）。

```
docker-compose down
```

## 補足: InSpecで正しくユーザーが作られているかチェックする

演習では事前に用意されたInSpecを用いて、正しく構築ができているかテストすることができます。  
すでにAnsibleを実行するコンテナにはInSpecがインストールされています。

InSpecの実行ファイルは現在、Chef Lisenceで提供されているため、実行の前に一度目を通しておいてください。  
[Chef EULA](https://www.chef.io/end-user-license-agreement)

上記を確認の上で、正しくユーザー作成できているか検証したい方は、以下を実行してみてください。

```sh
docker-compose exec control_node bash

inspec exec tests --config ./tests/config.json
```

成功したら、想定通りのユーザーが作成されています！

```
Profile: tests from tests (tests from tests)
Version: (not specified)
Target:  ssh://ec2-user@managed_node:22

  User test_user
     ✔  is expected to exist
     ✔  shell is expected to eq "/bin/bash"

Test Summary: 2 successful, 0 failures, 0 skipped
```

## 追加でチャレンジ！

* 01-4で行ったPlaybookの実行をもう一度やってみましょう
  * 何回実行しても期待している状態になっているか確認してみましょう
* 新しくグループを追加してみましょう
  * Hint: ansible.builtin.group モジュールを使いましょう
* 追加したグループがユーザーに設定されるようにしましょう
  * Hint: ansible.builtin.user モジュールのドキュメントを再度見てみましょう