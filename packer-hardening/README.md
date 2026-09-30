# Packer + Ansible: hardened Ubuntu AMI

Збірка AMI на AWS (Ubuntu 24.04) з використанням ролі
[`devsec.hardening.os_hardening`](https://github.com/dev-sec/ansible-collection-hardening/tree/master/roles/os_hardening).

## Як це працює

1. Packer (`amazon-ebs`) запускає тимчасовий EC2-інстанс з офіційного Ubuntu 24.04 AMI від Canonical.
2. Shell-провіжнер чекає на cloud-init і оновлює кеш apt.
3. Ansible-провіжнер встановлює колекцію `devsec.hardening` (`requirements.yml`) і застосовує роль `os_hardening` (`playbook.yml`).
4. Packer створює з інстансу AMI `hardened-ubuntu-2404-<timestamp>` і видаляє тимчасові ресурси.

## Вимоги

- Linux або WSL (Ansible не працює як control node на Windows)
- Packer >= 1.10, ansible-core >= 2.16
- AWS-креденшли в `~/.aws` (права на EC2 та AMI)

## Запуск

```bash
packer init .
packer validate .
packer build .
```

## Результат

- Збірка пройшла без помилок (`failed=0`), AMI створено: [screenshots/01-build-success.png](screenshots/01-build-success.png)
- AMI у статусі Available: [screenshots/02-ami-available.png](screenshots/02-ami-available.png)
- Перевірка на інстансі, запущеному з AMI: [screenshots/03-verification.png](screenshots/03-verification.png)

| Перевірка                          | Звичайна Ubuntu | Hardened AMI |
| ---------------------------------- | --------------- | ------------ |
| auditd                             | inactive        | active       |
| net.ipv4.conf.all.accept_redirects | 1               | 0            |
| net.ipv4.conf.all.send_redirects   | 1               | 0            |
| PASS_MAX_DAYS                      | 99999           | 60           |
| UMASK                              | не задано       | 027          |
| /etc/modprobe.d/dev-sec.conf       | відсутній       | є            |

## Проблеми під час виконання

- **404 при встановленні `auditd`**: базовий AMI містив застарілий кеш apt. Виправлено додаванням `apt-get update` перед запуском Ansible.

## Прибирання

Після перевірки інстанс терміновано, AMI дерегістровано, снепшот видалено.
