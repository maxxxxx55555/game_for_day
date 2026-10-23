# Очистка экрана и приветствие
Clear-Host
Write-Host "=== Автоматическая выгрузка проекта в GitHub ===" -ForegroundColor Cyan

# Проверяем, передан ли URL репозитория или запрашиваем его
$repoUrl = Read-Host "Введите URL вашего репозитория на GitHub (например, https://github.com/username/game_for_day.git)"

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "Ошибка: URL репозитория не может быть пустым!" -ForegroundColor Red
    exit
}

# Шаг 1: Инициализация git, если еще не сделано
if (!(Test-Path ".git")) {
    Write-Host "`n[1/5] Инициализация локального Git репозитория..." -ForegroundColor Yellow
    git init
} else {
    Write-Host "`n[1/5] Локальный Git уже инициализирован." -ForegroundColor Green
}

# Шаг 2: Добавление файлов
Write-Host "`n[2/5] Добавление всех файлов проекта в индекс..." -ForegroundColor Yellow
git add .

# Шаг 3: Создание коммита
$commitMsg = Read-Host "Введите сообщение коммита (по умолчанию: 'Update game version v2')"
if ([string]::IsNullOrWhiteSpace($commitMsg)) {
    $commitMsg = "Update game version v2"
}

Write-Host "`n[3/5] Создание коммита..." -ForegroundColor Yellow
git commit -m "$commitMsg"

# Шаг 4: Настройка ветки main и удаленного репозитория
Write-Host "`n[4/5] Привязка к удаленному репозиторию GitHub..." -ForegroundColor Yellow
git branch -M main

# Проверяем, привязан ли уже origin, если да — обновляем URL
$existingRemote = git remote get-url origin 2>$null
if ($LASTEXITCODE -eq 0) {
    git remote set-url origin $repoUrl
} else {
    git remote add origin $repoUrl
}

# Шаг 5: Отправка в репозиторий
Write-Host "`n[5/5] Загрузка файлов на GitHub (git push)..." -ForegroundColor Yellow
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n Успешно! Проект полностью загружен в ваш репозиторий GitHub." -ForegroundColor Green
} else {
    Write-Host "`n Возникла ошибка при отправке. Убедитесь, что у вас есть права доступа (возможно, потребуется токен доступа Personal Access Token или настроенный SSH)." -ForegroundColor Red
}