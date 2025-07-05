# Настройка релизной подписи приложения

## Текущая конфигурация

Конфигурация релизной подписи вынесена в отдельный файл `keystore.properties`:

```properties
storeFile=release-key.jks
storePassword=your_keystore_password
keyAlias=your_key_alias
keyPassword=your_key_password
```

Файл `build.gradle.kts` автоматически загружает эти параметры при сборке.

## Что нужно сделать для реальной подписи:

### 1. Сгенерировать keystore файл
```bash
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias your_key_alias
```

### 2. Обновить параметры в keystore.properties
Замените мок значения в файле `keystore.properties` на реальные:
- `your_keystore_password` - пароль keystore файла
- `your_key_alias` - алиас ключа
- `your_key_password` - пароль ключа

### 3. Файлы уже добавлены в .gitignore
Следующие файлы уже исключены из репозитория:
```
android/app/release-key.jks
android/app/*.jks
android/app/keystore.properties
```

### 4. Безопасное хранение паролей
Пароли теперь хранятся в отдельном файле `keystore.properties`, который исключен из репозитория.

## Текущий статус
- ✅ Конфигурация релизной подписи добавлена
- ✅ Мок параметры настроены
- ⏳ Требуется генерация реального keystore файла
- ⏳ Требуется обновление паролей на реальные 