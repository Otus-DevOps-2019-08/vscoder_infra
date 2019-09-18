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
  * С хоста `bastionhost` устанавливается соединение с `someinternalhost` посредством подключения к `appuser@10.156.0.4` с использованием ключа `~/.ssh/appuser`, это происходит даже если не добавлять ключ `~/.ssh/appuser` в ssh-agent
