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
* Выполнена авторизация terraform в google
  ```
  gcloud auth application-default login
  ```
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
* Добавлены публичные ключи для пользователей _appuser2_ и _appuser3_
  ```
  resource "google_compute_project_metadata_item" "ssh-keys1" {
    key = "ssh-keys"
    value = "appuser1:${file(var.public_key_path)}"
  }
  resource "google_compute_project_metadata_item" "ssh-keys2" {
    key = "ssh-keys"
    value = "appuser2:${file(var.public_key_path)}"
  }
  resource "google_compute_project_metadata_item" "ssh-keys3" {
    key = "ssh-keys"
    value = "appuser3:${file(var.public_key_path)}"
  }
  ```
  После применения, в метаданные проекта был добавлен только пользователь _appuser1_, а так же определённый для инстанса _appuser_. Подключение под обоими прошло успешно.
* Дополнительные ключи добавлены в один ресурс
  ```
  resource "google_compute_project_metadata_item" "ssh-keys" {
  key = "ssh-keys"
  value = <<EOF
    appuser1:${file(var.public_key_path)}
    appuser2:${file(var.public_key_path)}
    appuser3:${file(var.public_key_path)}
  EOF
  }
  ```
  После применения ключи в метаданные проекта добавлены, но на развёрнутый инстанс пользователи не приехали. В веб-интерфейсе в метаданных проекта появилось так же несколько _пустых_ ssh-ключей, с незаполненными значениями.
* Рабочим оказалось следующее решение:
  * `main.tf`
  ```
  resource "google_compute_project_metadata_item" "ssh-keys" {
    key = "ssh-keys"
    value = join("\n", var.ssh_keys)
  }
  ```
  * `variables.tf`
  ```
  variable ssh_keys {
    type    = list(string)
  }
  ```
  * `terraform.tfvars`
  ```
  ssh_keys = [
    "appuser:ssh-rsa <key_value_here> appuser",
    "appuser1:ssh-rsa <key_value_here> appuser",
    "appuser2:ssh-rsa <key_value_here> appuser",
    "appuser3:ssh-rsa <key_value_here> appuser"
  ]
  ```
  На инстансе были созданы все 4 пользователя
  **Примечание:** Экспериментальным путём установлено, что использование параметра метаданных `block-project-ssh-keys = false` необязательно
  **Примечание:** Использовать функцию `file()` при задании значений переменных в файле `terraform.tfvars` не удалось, так как не поддерживается. TODO: Выяснить как это реализовать
* Выполнена попытка добавить ключ пользователя _appuser_ с комментарием _appuswer_web_. В результате gcp выдал ошибку
  ```
  Supplied fingerprint does not match current metadata fingerprint.
  ```
  и дальнейшие попытки изменить состав ключей были неудачными
* В веб-интерфейса заново открыт список ключей, далее:
  * Сгенерирован новый ssh-ключ _appuser_web_
  ```
  ssh-keygen -t rsa -f ~/.ssh/appuser_web -C appuser_web -P ""
  ```
  * Сгенерированный ключ добавлен в метаданные проекта через веб-нитерфейс -- ключ успешно был добавлен, но войти под пользователем _appuser_web_ **не удалось** -- ошибка авторизации
  * Выполнено применение инфраструктуры `terraform apply` -- terraform созданный вручную ключ удалил

### Задания с **

При разработке использовались следующие ресурсы:
* https://cloud.google.com/load-balancing/docs/https/

Что было сделано:
* Создан файл `lb.tf`, в котором описаны следующие сущности:
  * google_compute_instance_group со списком инстансов ВМ с запущенным приложением (пока 1 экземпляр)
  * google_compute_health_check для проверки доступности приложения на экземпляре ВМ
  * google_compute_backend_service со ссылкой на группы экземпляров ВМ (в данном случае на 1 группу), а так же со ссылкой на google_compute_health_check
  * google_compute_url_map с описанием запросу к какому url на какой backend_service отправлять (в нашем случае все запросы ко всем url отправляются на 1 сервис)
  * google_compute_target_http_proxy для проксирования http/https соединений к url_map
  * google_compute_global_forwarding_rule для перенаправления ip4/ip6 трафика (для каждого типа трафика должно быть своё правило) на target_http_proxy (в нашем случае только ip4)
  * так же была добавлена output-переменная, выводящая ip балансировщика
* Изменение количества инстансов было реализовано посредством добавления имени нового инстанса в множество _instances_ в файл `terraform.tfvars`
* Output-переменная _app_external_ip_ теперь отображает список ip-адресов всех инстансов
* Добавлен второй инстанс ВМ с приложением. Решены возникшие в процессе настройки проблемы.
  **Важно:** google compute backend service очень долго стартует, в результате чего приложение через балансировщик становится доступным спустя продолжительное время (возможно более 10 минут)
* Выполнена остановка приложения на одном из инстансов. Интерфейс приложения остался доступен через балансировщик как и прежде.
* Код изменён таким образом, чтобы использоать переменную _instance_count_, указывающую количество необходимых инстансов, вместо _instances_, содержащей множество имён необходимых инстансов
  * _variables.tf_
    ```
    variable instance_count {
      type    = number
      default = 1
    }
    ```
  * _main.tf_
    ```
    resource "google_compute_instance" "app" {
      name         = "reddit-app${count.index}"
      count        = var.instance_count
      ...
    }
    ```
  * _outputs.tf_
    ```
    output "app_external_ip" {
      value = google_compute_instance.app[*].network_interface[0].access_config[0].nat_ip
    }
    ```
  * _lb.tf_
    ```
    resource "google_compute_instance_group" "app_instance_group" {
      instances = google_compute_instance.app[*].self_link
      ...
    ```
* Протестирована отказоустойчивость

## HomeWork 7: Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform

### Основное задание

* Файл `lb.tf` из предыдущего задания с ** перемещён в поддиректорию `terraform/files/`
* В `main.tf` описано правило фаервола `firewall_ssh`
  При применении возникла ошибка
  ```
  Error: Error creating Firewall: googleapi: Error 409: The resource 'projects/infra-253214/global/firewalls/default-allow-ssh' already exists, alreadyExists
  ```
  так как правило с таким именем уже присутствует в проекте
* Выполнен импорт правила из GCP в terraform state
  ```
  terraform import google_compute_firewall.firewall_ssh default-allow-ssh
  ```
* К ресурсу добавлено описание правила. Изменения применены `terraform apply`

* В `main.tf` определён ресурс `google_compute_address.app_ip reddit-app-ip`
* Инфраструктура пересоздана
  ```
  terraform destroy
  terraform apply
  ```
* Добавлена ссылка google_compute_instance.app network_interface access_config nat_ip на созданный статический ip

* Создан файл `packer/db.json`, описывающий packer-образ `reddit-db-base` для БД (mongodb)
* Создан файл `packer/app.json`, описывающий packer-образ `reddit-app-base` для app (ruby)
* Создан скрипт `packer/build_image.sh` для создания образов из json-файлов
* Запечены образы `reddit-db-base` и `reddit-app-base`
  ```
  ./build_image.sh db.json
  ./build_image.sh app.json
  ```

* Добавлен файл `terraform/app.tf` с описанием создания инстанса `reddit-app`, а так же:
  * статисеского адреса
  * правила фаервола
* Добавлен файл `terraform/db.tf` с описанием создания инстанса `reddit-db`, а так же:
  * правила фаервола
* Из `terraform/main.tf` убрано описание
  * инстанса `reddit-app`
  * правила фаервола для доступа к `reddit-app`
  * статического ip-адреса
* В `terraform/variables.tf` добавлены пеерменные базовых образов диска для app и db
  * app_disk_image
  * db_disk_image
* Правило фаервола для доступа к ssh вынесено из `terraform/main.tf` в `terraform/vpc.tf`
* Метаданные проекта вынесены из `terraform/main.tf` в `terraform/metadata.tf`
* Требования к версии terraform вынесены из `terraform/main.tf` в `terraform/metadata.tf`

* В директории `terraform/` создана поддиректория `modules/` для описания локальных модулей
* Описание инстанса `reddit-app` перенесено в модуль `modules/app/`, а так же
  * описание статического ip
  * описание правила фаервола
  * входящие переменные `public_key_path`, `zone`, `app_disk_image`
  * выходящая переменная `app_external_ip` (впоследствии будет получена в `outputs.tf` основного модуля)
* Описание инстанса `reddit-db` перенесено в модуль `modules/db/`, а так же
  * описание правила фаервола
  * входящие переменные `public_key_path`, `zone`, `db_disk_image`
* Созданные модули загружены в проект
  ```
  terraform get
  ```
* Правило фаервола для ssh перенесено из `vpc.tf` в отдельный модуль `modules/vpc/`, а так же:
  * входящяя переменная `zone`
* Созданные модули загружены в проект
  ```
  terraform get
  ```
* Инфраструктура создана `terraform apply`
* Успешно выполнено подключение по ssh к созданному инстансу
* Параметризована переменная `source_ranges` модуля `vpc`
* Протестирована работа переменной `source_ranges`
  * При задании своего белого ip подключение по ssh к созданному инстансу выполняется успешно
  * При задании любого другого белого ip, подключение не удалось
    *ЗАМЕЧАНИЕ:* Фактичетски изменение `source_ranges` применяется спустя несколько десятков секунд после завершения выполнения команды `terraform apply`

* Конфигурация разнесена по 2-м окружениям
  * *stage* - доступ к ssh открыт со всех ip
  * *prod* - доступ к ssh открыт только с моих ip
* Из корня terraform-проекта удалены файлы, скопированные в каждое из окружений
  * `terraform/main.tf`
  * `terraform/outputs.tf`
  * `terraform/variables.tf`
  * `terraform/terraform.tfvars`
* Проверена правильность настроке инфраструктуры каждого из окружений посредством `terraform apply`
* Для модулей параметризовано имя окружения (stage/prod)
* Для каждого окружения создаётся отдельная сеть с именем `${var.network_name}-${var.environment}`
* Для модуля app параметризовано создание ресурса `google_compute_address`, а так же назначение его инстансу.
  Создание ресурса только если `var.use_static_ip` истина
  ```
  resource "google_compute_address" "app_ip" {
    name = "reddit-app-ip-${var.environment}"
    count = var.use_static_ip ? 1 : 0
  }
  ```
  Назначение статического адреса только если `var.use_static_ip` истина
  ```
  network_interface {
    network = "${var.network_name}-${var.environment}"
    access_config {
      nat_ip = var.use_static_ip ? google_compute_address.app_ip[0].address : null
    }
  }
  ```
* Добавлен файл `storage-bucket.tf`, содержащий модуль `SweetOps/storage-bucket/google`
* Для загрузки недостающих модулей выполнен `terraform init`
* Для функционирования в секцию `module` понадобилось добавить/изменить передаваемые параметры
  ```
  name     = "storage-bucket-test-${var.project}"
  location = var.region
  ```
* Проверена работоспособность `terraform apply`

### Задания со * Хранение state в gcs

**ВАЖНО:** Перед изменением `backend.tf` не забывать удалять текущую инфраструктуру `terraform destroy`

**Примечание:** дял корректной работы с `backend` понадобилось убрать подстановку переменной в имя `storage-bucket`, так как *the backend configuration does not support variables or expressions of any sort*. Работу с переменными в бэкэндах, а так же поддерживать инфраструктурный код *DRY and maintenable* позволяет [terragrunt](https://github.com/gruntwork-io/terragrunt)

* Создан `stage/backend.tf` с описанием remote backend для хранения состояния
  ```
  terraform {
    backend "gcs" {
      bucket = "vscoder-otus-tf-state"
      prefix = "terraform/state"
    }
  }
  ```
* Файлы `*.tfstate*` и `.terraform` вынесены из репозитория во внешнюю директорию
* Выполнена инициализация `terraform init`
* stage-инфраструктура развёрнута `terraform apply`.
  Как и ожидалось, файлы состояния в директории не появились:
  ```
  .
  ├── backend.tf
  ├── main.tf
  ├── outputs.tf
  ├── terraform.tfvars
  ├── terraform.tfvars.example
  └── variables.tf

  0 directories, 6 files
  ```
* Файл `stage/backend.tf` скопирован в `prod/backend.tf` без изменений
* При выполнении `terraform plan` - все ресурсы запланированы к пересозданию. Такое поведение не устраивает.
  ```
  Plan: 7 to add, 0 to change, 6 to destroy.
  ```
* В обоих окружениях в `backend.tf` изменён `prefix`
  Было: `prefix = "terraform/state"`
  Стало: `prefix = "terraform/state/stage"` и `prefix = "terraform/state/prod"` соответственно
* Применение инфраструктуры (`terraform apply`) для каждого из окружений прошло успешно. Одновременно.
* `terraform show` для каждого из окружений выдаёт свой набор объектов
* При попытке применить изменения (`terraform apply`) одновременно (из разных терминалов) для одного окружения, во втором терминале terraform выдал ошибку:
  ```
  Error: Error locking state: Error acquiring the state lock: writing "gs://vscoder-otus-tf-state/terraform/state/prod/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet
  ```
  что говорит о корректной работе блокировок

### Задание с ** Провиженинг приложения с использованием пременных окружения

* В модуль `db` добавлена output-переменная `db_internal_ip` для передачи в модуль `app`
  ```
  output "db_internal_ip" {
    value = google_compute_instance.db.network_interface[0].network_ip
  }
  ```
* В окружении `stage` данная переменная передаётся модулю `app` как часть переменной `database_url`
  ```
  database_url    = "${module.db.db_internal_ip}:27017"
  ```
* В модуле `app`
  * создана input variable `database_url` для передачи провиженеру
    ```
    variable database_url {
      description = "MongoDB url. Ex: 127.0.0.1:27017"
    }
    ```
  * в `google_compute_instance` добавлены провиженеры
    * заполняющий на основе переменной `var.database_url` файл `puma.env`
      ```
      provisioner "file" {
        content      = "DATABASE_URL=${var.database_url}"
        destination = "/tmp/puma.env"
      }
      ```
    * передающий на инстанс шаблон systemd-юнита для запуска puma server
      ```
      provisioner "file" {
        source      = "${path.module}/files/puma.service.tmpl"
        destination = "/tmp/puma.service.tmpl"
      }
      ```
    * выполняющий на инстансе скрипт `deploy.sh`
      ```
      provisioner "remote-exec" {
        script = "${path.module}/files/deploy.sh"
      }
      ```
  * В шаблоне systemd-юнита `puma.service.tmpl`:
    * параметризован путь к директории с приложением
    * параметризован пользователь от имени которого запускается приложение
    * Добавлен параметр `EnvironmentFile` для передачи переменных из файла `puma.env` в качестве переменных окружения запускаемому приложению
      ```
      [Service]
      EnvironmentFile=${APP_DIR}/puma.env
      ...
      ```
  * В файле `deploy.sh` выполняются следующие действия:
    * экспортируется переменная `$APP_DIR` для корректной подстановки в шаблон systemd-юнита
    * из репозитория устанавливается приложение в `$APP_DIR`
    * файл с переменными окружения `puma.env` перемещается из временной директории в `$APP_DIR`
    * в systemd добавляется сервис `puma.service` из шаблона `/tmp/puma.service.tmpl`
      ```
      cat /tmp/puma.service.tmpl | envsubst | sudo tee /etc/systemd/system/puma.service
      ```
    * `puma.service` запускается и добавляется в автозагрузку
  * Помимо перечисленного, в stage-окружение добавлены дополнительные output variables
  * **НО** при запуске приложения, оно не смогло подключиться к БД по причине того, что MongoDB по умолчанию запускается на адресе `127.0.0.1`

  * Запуск mongod сервиса на `0.0.0.0` исправлен добавлением в модуль `db` провиженера, заменяющено `bindIp: 127.0.0.1` на `bindIp: 0.0.0.0` в конфигурационном файле `mongod.conf` и перезапускающего сервис
    ```
    provisioner "remote-exec" {
      inline = [
        "sudo sed -i.bak 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf",
        "sudo systemctl restart mongod.service"
      ]
    }
    ```
  * Приложение **работает** на http://<app_external_ip>:9292
