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
  ```
  testapp_IP = 35.233.91.245
  testapp_port = 9292
  ```

### Самостоятельная работа

Создано 3 скрипта, реализующие все необходимые действия для развёртывания приложения на вновь созданном хосте:
* `install_ruby.sh` - для установки ruby
* `install_mongodb.sh` - для установки MongoDB
* `deploy.sh` - дял деплоя приложения

### Дополнительное задание 1

Создан скрипт `init.sh`, который
* На основе install_ruby.sh, install_mongodb.sh и deploy.sh, один общий скрипт `startup.sh`
  ```
  cat install_ruby.sh install_mongodb.sh deploy.sh > startup.sh
  ```
* Выполняет команду gcloud, которая создаёт инстанс ВМ и инициализирует его, запуская `startup.sh`, если инстанс с таким именем ещё не был создан
  ```
  gcloud compute instances create reddit-app\
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --restart-on-failure \
    --metadata-from-file startup-script=startup.sh
  ```

### Дополнительное задание 2

Скрипт `init.sh` изменён таким образом, чтобы:
* Вместо использования локального startup-скрипта при инициальзации ВМ, загружает `startup.sh` в bucket на File Storage и создаёт ВМ посредством команды
  ```
  gcloud compute instances create reddit-app\
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags "puma-server" \
    --restart-on-failure \
    --metadata startup-script-url=gs://vscoder-otus-hw4/startup.sh
  ```
* Создаёт правило фаервола _default-puma-server_, которое разрешает доступ на инстансы с тэгом _puma-server_ на tcp port 9292
  ```
  gcloud compute firewall-rules create default-puma-server \
  --allow=tcp:9292 \
  --target-tags="puma-server"
  ```

### Прочее

* Инициализация переменных перенесена в файл `.env`, который, в свою очередь, импортируется в `init.sh` командой
  ```
  source .env
  ```
* Добавлен скрипт `clean.sh`, который удаляет созданные объекты GCP
* При повторном запуске `init.sh`, ресурсы заново не создаются. Только выводится информация о созданном инстансе. Например:
  ```
  *** Check instance 'reddit-app' exists
  VM external IP is 35.233.91.245
  *** Create firewall rule, if not exists
  Completed. Service will be accessible soon at http://35.233.91.245:9292
  ```

## HomeWork 5: Сборка образов VM при помощи Paker

### Основное задание

* Установлен [packer](https://www.packer.io/downloads.html)
* Выполнена авторизация `gcloud auth application-default login`
* Создан файл `packer/ubuntu16.json` с описанием базового образа _reddit-base_
* Из [cloud-testapp](https://github.com/Otus-DevOps-2019-08/vscoder_infra/tree/cloud-testapp) скопированы и адаптированы скрипты установки ruby и MongoDB
* Скрипты добавлены в секцию _provisioning_ описания образа
* Успешно собран образ командой `packer build ubuntu16.json`
* Для автоматизации создания образа создан скрипт `init_base.sh`
* На основе образа _reddit-base_ развёрнут экземпляр ВМ
* На ВМ развёрнут puma server с тестовым приложением

### Самостоятельные задания

* Параметризованы переменные
* Добавлен файл-пример с обязательными переменными `variables.json.example`
  Важно: если задать значение переменной _network_ отличное от **default**, необходимо предварительно создать соответствующую сеть. Необходимо так же задать значение параметру _subnetwork_
  >  Only required if the network has been created with custom subnetting. Note, the region of the subnetwork must match the region or zone in which the VM is launched. [link](https://www.packer.io/docs/builders/googlecompute.html#subnetwork)

* Создана сеть `testnetwork`
* Для сети создано **правило брендмауера**, разрешающее доступ к 22 порту (иначе packer не может подключиться к ВМ)

### Первое задание со *

* Создан шаблон `immutable.json` с описанием образа _reddit-full_, основаного на _reddit-base_ и содержащего в себе развёрнутое приложение
* Приложение разворачивается скриптом `deploy.sh`, в процессе развёртывания:
  * Склонирован github-репозиторий
  * Установлены зависимости
  * Обеспечен запуск сервера приложения посредством systemd unit-файла
    Содержимое `reddit-app.service` файла описано непосредственно в скрипте `deploy.sh`
  * Включена автозагрузка `reddit-app.service`
  * Проверена работоспособность `reddit-app.service`:
    * Старт
    * Рестарт
    * Статус
    * Стоп
* В случае успешного выполнения всех шагов скрипта, создаётся и заливается в GCP packer-образ _reddit-full_
* Для автоматизации описаных шагов создан скрипт `init_full.sh`

### Второе задание со *

Создан скрипт `config-scripts/create-reddit-vm.sh`, который:
* С помощью утилиты `gcloud` создаёт ВМ _reddit-full_, если такой не существует (иначе пропускает этот шаг)
  ВМ создаётся с тегом _puma-server_
* Сообщает пользователю белый IP созданной или существующей ВМ
* Создаёт правило фаервола _default-puma-server_ (если не существует), которое разрешает трафик на tcp-порт 9292 всех ВМ с тегом _puma-server_
* Сообщает пользователю URL для подключения к запущенному приложению

Замечание: указанный скрипт проверяет существования экземпляра ВМ и правила фаервола только по имени. В случае если экземпляр ВМ или правило фаервола с соответствующим именем уже существует, но отличается по свойствам, оно пересоздано **не будет**! Необходимо вручную удалить соответствующий объект чтобы скрипт создал его заново с нужными свойствами.

## HomeWork 6: Практика IaC с использованием Terraform

### Основное задание

* Установлен terraform
* В `.gitignore` добавлены временные и приватные файлы terraform-проекта
* Создан файл `main.tf`, в который добавлены секции 
  * _terraform_ требованиями к версии `terraform`
  * _provided "google"_ со специфичными для GCP параметрами
* Проект проинициализирован командой `terraform init`, в процессе чего загружены необходимые для работы с GCP модули
* В `main.tf` добавлено базловое описание инстанса ВМ
  * имя
  * тип
  * зона
  * семейство образов загрузочного диска (будет браться последняя версия)
  * сетевой интерфейс
* Создан экземпляр ВМ
  ```
  terraform plan
  terraform apply
  ```
  Поле этого создаётся файл `terraform.tfstate` с описанием текущей инфраструктуры
  **Важно:** Если базовый образ был обновлён после создания инстанса ВМ, это никак не повлияет на уже созданную ВМ. Для использования нового базового образа, инстанс ВМ нужно пересоздать посредством команды `terraform taint google_compute_instance.<resource name>`
* Добавлены метаданные, оисывающие публичный ключ, который необходимо загрузить на созданный инстанс
  ```
  resource ... {
  ...
    metadata = {
      ssh-keys = "user"${file("path_to_key.pub")}"
    }
  ...
  }
  ```
  **Примечание:** Работает так же для уже созданной ВМ. После применения изменений, к инстансу удалось подключиться пл ssh
* Создан файл `outputs.tf` со списком переменных, показываемых после применения изменений. В этот файл добавлен внешний адрес созданного инстанса
  ```
  output "app_external_ip" {
    value = google_compute_instance.<resource_name>.network_interface[0].access_config[0].nat_ip
  }
  ```
* В файл `main.tf` добавлен ресурс _google_compute_firewall_ с описанием правила фаервола, разрешающего доступ к порту сервера приложения. Соответствующий тег добавлен к экземпляру ВМ
* В проект добавлены файлы `files/puma.service` и `files/deploy.sh`, необходимые для провиженинга создаваемого инстанса
* В файл `main.tf` в ресурс _google_compute_instance_ добавлены 2 провиженера:
  * тип _file_ для копирования systemd unit- файла на инстанс
    ```
      provisioner "file" {
      source      = "files/puma.service"
      destination = "/tmp/puma.service"
    }
    ```
  * тип _remote-exec_ для запуска на инстансе скрипта `files/deploy.sh`
    ```
    provisioner "remote-exec" {
      script = "files/deploy.sh"
    }
    ```
  * Описана секция _connection_ с описанием способа подключения провиженеров к инстансу ВМ
* С целью выполнения провиженеров, пересоздане экземпляра ВМ форсировано командой `terraform taint google_compute_instance.<resource name>`
* Посредством использования input-переменных параметризованы следующие параметры:
  * _project_ имя проекта
  * _region_ регион
  * _public_key_path_ путь к публичному ssh-ключу, загружаемому на инстанс ВМ
  * _disk_image_ имя базового образа для загрузочного диска
* Обязательные параметры определены в файле `terraform.tfvars`, который игнорируется git-ом

### Самостоятельные задания

* Определена обязательная input-переменная _private_key_path_, значением которой является путь к закрытому ssh-ключу, использующемуся при подключени провиинеров
* Определена input-переменная _zone_, задающая зону, в которой должен создаваться экземпляр ВМ
* Все `*.tf` файлы отформатированы командой `terraform fmt`
* Создан файл ` terraform.tfvars.example` с примерами обязательных переменных

### Задания со *

* Добавлен публичный ssh-ключ, общий для всего проекта
  ```
    resource "google_compute_project_metadata_item" "sshkey-appuser1" {
    key = "ssh-keys"
    value = "appuser1:${file(var.public_key_path)}"
  }
  ```
  После применения, на ранее созданной ВМ автоматически был создан пользователь _appuser1_ с добавленным к нему указанным ключом. Попытка подключения по ssh под именм данного пользователя прошла успешно.
