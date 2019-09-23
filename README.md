# vscoder_infra
Aleksey Koloskov OTUS-DevOps-2019-08 Infra repository

# Домашние задания

## HomeWork 2: GitChatOps

* Создан шаблон PR
* Создана интеграция с TravisCI
```bash
 travis encrypt "devops-team-otus:<ваш_токен>#<имя_вашего_канала>" --add notifications.slack.rooms --com
```
* Создана интеграция с чатом для репозитория
* Создана интеграция с чатом для TravisCI
* Отработаны навыки работы с GIT

## HomeWork 3: Знакомство с облачной инфраструктурой. Google Cloud Platform

* Создана УЗ в GCP
* Созданы 2 ВМ: bastionhost с внешним IP и someinternalhost тосько с внутренним ip
* Настроено сквозное подключение по SSH к хосту someinternalhost посредством выполнения команды
`ssh someinternalhost` для чего:
  * при создании ВМ сгенерирован ssh-ключ `appuser`
  * ключ appuser добавлен в ssh-агент
  * в файл `~/.ssh/config` добавлены строки
    ```
    Host bastionhost
        IdentityFile ~/.ssh/appuser
        User appuser
        HostName 34.89.159.155
    Host someinternalhost
        IdentityFile ~/.ssh/appuser
        User appuser
        HostName 10.156.0.4
        ProxyJump bastionhost
    ```
  В результате, при выполнении команды `ssh someinternalhost`, происходит следующее:
  * Устанавливается соединение с `bastionhost` посредством подключения к `appuser@34.89.159.155` с использованием ключа `~/.ssh/appuser`
  * С хоста `bastionhost` устанавливается перенаправление TCP на `someinternalhost` посредством подключения к `appuser@10.156.0.4` с использованием ключа `~/.ssh/appuser`, это происходит даже если не добавлять ключ `~/.ssh/appuser` в ssh-agent
  * Аналогом директивы ProxyJump может быть опция `-J <jump host>` команды `ssh`, например
    ```shell
    ssh-add -L ~/.ssh/appuser
    ssh -i ~/.ssh/appuser -J appuser@34.89.159.155 appuser@10.156.0.4
    ```
    В случае такого способа, ssh-ключь должен быть добавлен в ssh-агент, иначе возникает ошибка
    ```
    appuser@34.89.159.155: Permission denied (publickey).
    ssh_exchange_identification: Connection closed by remote host
    ```
* Установлен и настроен vpn-сервер [pritunl](https://pritunl.com)
  ```
  bastion_IP = 34.89.159.155
  someinternalhost_IP = 10.156.0.4
  ```
  * Создана организация
  * Создан пользователь
  * Создан сервер
  * Добавлен маршрут ко внутренней сети
  * Сервер прикреплён к организации
* Административный интерфейс доступен так же по адресу https://34-89-159-155.sslip.io через sslip.io
* Создано доменное имя bastion.vscoder.ru, разрешаемое в ip 34.89.159.155
* При подключении к https://bastion.vscoder.ru используется сертификат от Let's Encrypt

## HomeWork 4: Деплой тестового приложения

### Основное задание

* Установлен и настроен [gcloud](https://cloud.google.com/sdk/gcloud/) для работы с нашим аккаунтом
* Создан хост с помощью gcloud
  ```
  gcloud compute instances create reddit-app\
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --restart-on-failure
  ```
* Установлен ruby
* Установлен MongoDB 3.2
* Задеплоено тестовое приложение

### Самостоятельная работа

Создано 3 скрипта, реализующие все необходимые действия для развёртывания приложения на вновь созданном хосте: 
* `install_ruby.sh` - для установки ruby
* `install_mongodb.sh` - для установки MongoDB
* `deploy.sh` - дял деплоя приложения

### Дополнительное задание

Создан скрипт `init.sh`, который
* На основе install_ruby.sh, install_mongodb.sh и deploy.sh, один общий скрипт `startup.sh`
  ```
  cat install_ruby.sh install_mongodb.sh deploy.sh > startup.sh
  ```
* Выполняет команду gcloud, которая создаёт инстанс ВМ и инициализирует его, запуская `startup.sh`
  ```
  gcloud compute instances create reddit-app\
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --restart-on-failure \
    --metadata-from-file startup-script=$STARTUP_SCRIPT
  ```
