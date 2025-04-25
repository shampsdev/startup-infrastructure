# Startup Infrastructure
Этот репозиторий — часть серии статей на Хабре о том, как с минимальными усилиями и затратами построить DevOps-инфраструктуру для небольших проектов.  
В первой части мы сосредоточились на базовой настройке окружения.

[Часть 1 — Настройка окружения](https://habr.com/ru/articles/904234/)
[Часть 2 — пока готовится..]()

You can find the English version of this README here: [README in English](README.en.md)

## Описание
Инфраструктура ориентирована на стартапы, которые не имеют бюджета на полноценную команду DevOps, но нуждаются в надёжной и масштабируемой системе с минимальными затратами. Мы рассмотрели использование Docker Swarm как альтернативу Kubernetes, поскольку это решение легче в настройке и обслуживании.

Технологии:
- **Docker Swarm** — лёгкая альтернатива Kubernetes для оркестрации.
- **Portainer** — GUI для управления Docker-инфраструктурой.
- **Traefik** — современный reverse-proxy с поддержкой auto SSL.

## Быстрый старт

### 1. Инициализация нод

Установите зависимости и инициализируйте Swarm (на мастер-ноде):
```bash
curl -fsSL https://raw.githubusercontent.com/shampsdev/startup-infrastructure/main/init.sh | bash -s -- m
docker swarm init --advertise-addr <your-private-ip>
```

Подключите воркер-ноды:
```
curl -fsSL https://raw.githubusercontent.com/shampsdev/startup-infrastructure/main/init.sh | bash -s -- w
docker swarm join --token <token> <master-ip>:2377
```

### 2. Установка Portainer
Portainer помогает управлять кластерами через удобный веб-интерфейс.
```
curl -o docker-compose.yaml https://raw.githubusercontent.com/shampsdev/startup-infrastructure/main/portainer-traefik/portainer.docker-compose.yaml
docker stack deploy -c docker-compose.yaml portainer
```
Откройте `http://<server-ip>:9000` и создайте пользователя.

### 3. Настройка Traefik
Traefik отвечает за маршрутизацию и SSL.
- Создайте конфиг в Portainer: Configs > Add config.
- Вставьте содержимое `traefik.docker-compose.yaml` и настройте стек в Stacks > Add stack.
- Сгенерируйте пароль для доступа к дашборду:
    ```
    echo $(htpasswd -nB admin) | sed -e s/\\$/\\$\\$/g
    ```
При подключении сервисов можете использовать такие лейблы:
```
labels:
  - "traefik.enable=true"
  - "traefik.docker.network=traefik"
  - "traefik.http.routers.my-service.rule=Host(`example.com`)"
  - "traefik.http.routers.my-service.entrypoints=https"
  - "traefik.http.routers.my-service.certresolver=letsEncrypt"
  - "traefik.http.services.my-service.loadbalancer.server.port=80"
```

### 4. Структура репозитория
```
startup-infrastructure/
├── init.sh                          # Скрипт инициализации нод
├── portainer-traefik/
│   ├── portainer.docker-compose.yaml
│   ├── traefik-config-v1            # Конфиг для траефика
│   └── traefik.docker-compose.yaml
└── README.md                        # Описание и документация
```