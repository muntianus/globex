# Настройка SSL сертификатов

Эта директория содержит SSL/TLS сертификаты для nginx reverse proxy в настройке docker-compose.

## Обзор

Контейнер nginx в `docker-compose.yml` монтирует эту директорию в `/etc/nginx/ssl` и использует сертификаты для включения HTTPS на порту 443.

## Файлы сертификатов

### Ожидаемые имена файлов
- `fullchain.pem` - Цепочка сертификатов (сертификат + промежуточные сертификаты)
- `privkey.pem` - Файл приватного ключа

### Альтернативные имена
Если вы используете другие имена файлов, обновите пути в `frontend/nginx.conf`:
```nginx
ssl_certificate /etc/nginx/ssl/your-cert.pem;
ssl_certificate_key /etc/nginx/ssl/your-key.pem;
```

## Настройка для разработки (Самоподписанные сертификаты)

### Быстрая настройка для локальной разработки
```bash
# Генерировать самоподписанный сертификат для localhost
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout privkey.pem -out fullchain.pem \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,DNS:127.0.0.1,IP:127.0.0.1"
```

### Более безопасная настройка для разработки
```bash
# Создать более комплексный самоподписанный сертификат
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
  -keyout privkey.pem -out fullchain.pem \
  -config <(
    echo '[req]'
    echo 'distinguished_name = req'
    echo 'x509_extensions = v3_req'
    echo 'prompt = no'
    echo '[req]'
    echo 'C = US'
    echo 'ST = State'
    echo 'L = City'
    echo 'O = Organization'
    echo 'CN = localhost'
    echo '[v3_req]'
    echo 'keyUsage = keyEncipherment, dataEncipherment'
    echo 'extendedKeyUsage = serverAuth'
    echo 'subjectAltName = @alt_names'
    echo '[alt_names]'
    echo 'DNS.1 = localhost'
    echo 'DNS.2 = *.localhost'
    echo 'IP.1 = 127.0.0.1'
  )
```

## Настройка для продакшена

### Let's Encrypt (Рекомендуется)
```bash
# Установить certbot
sudo apt-get install certbot

# Генерировать сертификат для вашего домена
sudo certbot certonly --standalone -d yourdomain.com

# Скопировать сертификаты в эту директорию
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ./fullchain.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ./privkey.pem
sudo chown $USER:$USER *.pem
```

### Коммерческий сертификат
1. Купить SSL сертификат у доверенного CA
2. Генерировать Certificate Signing Request (CSR):
   ```bash
   openssl req -new -newkey rsa:2048 -nodes -keyout privkey.pem \
     -out certificate.csr -subj "/C=US/ST=State/L=City/O=Organization/CN=yourdomain.com"
   ```
3. Отправить CSR в ваш центр сертификации
4. Скачать цепочку сертификатов и поместить как `fullchain.pem`
5. Сохранить ваш приватный ключ как `privkey.pem`

## Лучшие практики безопасности

### Права доступа к файлам
```bash
# Установить ограничительные права доступа на приватный ключ
chmod 600 privkey.pem
chmod 644 fullchain.pem
```

### Проверка сертификатов
```bash
# Проверить детали сертификата
openssl x509 -in fullchain.pem -text -noout

# Проверить срок действия сертификата
openssl x509 -in fullchain.pem -noout -dates

# Протестировать SSL соединение
openssl s_client -connect localhost:443 -servername localhost
```

## Устранение неполадок

### Частые проблемы

1. **Сертификат не найден**: Убедитесь, что файлы названы правильно и находятся в директории `ssl/`
2. **Доступ запрещен**: Проверьте права доступа к файлам (600 для приватного ключа, 644 для сертификата)
3. **Сертификат истек**: Обновите сертификаты до истечения срока действия
4. **Предупреждения браузера**: Самоподписанные сертификаты будут показывать предупреждения безопасности в браузерах

### Тестирование HTTPS
```bash
# Тест с curl
curl -k https://localhost

# Тест с openssl
openssl s_client -connect localhost:443 -servername localhost
```

## Интеграция с Docker

Сертификаты автоматически монтируются в контейнер nginx:
```yaml
volumes:
  - ./ssl:/etc/nginx/ssl
```

Убедитесь, что перезапустили контейнер nginx после обновления сертификатов:
```bash
docker compose restart nginx
```

## Важные замечания

- **Никогда не коммитьте приватные ключи** в систему контроля версий
- **Используйте надежные пароли** для шифрования приватного ключа в продакшене
- **Отслеживайте срок действия сертификатов** и настройте автоматическое обновление
- **Тестируйте конфигурацию SSL** после любых изменений
- **Поддерживайте сертификаты в актуальном состоянии** для соответствия требованиям безопасности

