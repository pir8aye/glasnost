# Запуск Glasnost с помощью Docker

```
docker run -it -p 80:80 --restart on-failure:10 ontofractal/glasnost:latest
```

# Обновление образа Docker перед установкой новой версии Glasnost

Если вы использовали более раннюю версию Glasnost, то перед запуском новой версии надо обновить Docker образ:
```
docker pull ontofractal/glasnost:latest
```

# Админка

Теперь в Glasnost можно обновлять конфигурацию без перезагрузки. Glasnost не загружает конфинг при запуске. До подтверждения сохранения, ключ админа (меняющийся после перезагрузки приложения) находится на странице `/admin`. После этого в админке нужно ввести URL конфига и сохраненный ключ. Точно так же конфиг обновляется. После обновления конфига Glasnost нужно от нескольких секунд до нескольких минут для синхронизации данных с блокчейном.

## Настройки конфига

Для выбора блокчейна и страницы "о блоге" используются следующие свойства JSON конфига.

* `"source_blockchain"`: `steem` или `golos`
* `"about_blog_author"`: имя автора (одного из указаных в `authors: [...]`) в `steem` или `golos`, который опубликовал пост с описанием блога
* `"about_blog_permlink"`: permlink (не полный урл) поста с описанием блога
* `"language"`: язык интерфейса Glasnost
* `"default_blockchain"`: блокчейн авторов по умолчанию
*  `"upgrade_insecure_requests"`: true|false

Как правило конфигурация приложений на Elixir происходит на этапе компиляции. Это означает, что
для изменений такие переменных пространства, как `PORT`, `STEEM_URL` и `GOLOS_URL` необходимо внести новые значения в Dockerfile и создать новый имидж с обновленными переменными среды.

## Проверка конфига

Конфиг должен был валидным JSON, проверить на валидность можно на [jsonlint.com](http://jsonlint.com/).

# Минимальный конфиг

```
{
  "authors": [{
    "account_name": "ontofractal",
    "source_blockchain": "golos",
    "filters": {}
  }],
  "about_blog_permlink": "anons-open-sors-platformy-dlya-razrabotki-prilozhenii-na-blokcheine-golos-fidbek-privetstvuetsya",
  "about_blog_author": "ontofractal",
}
```

`source_blockchain` имеет более высокий приоритет по сравнению с `default_blockchain`.

## Конфигурация меню

На данный момент в меню возможно настроить несколько (ограничение по ширине на мобильных устройствах) элементов верхнего уровня. Для каждого элемента верхнего уровня можно добавить элементы дропдауна. Верхний элемент не может быть ссылкой. Для элементов дропдауна используется следующий формат: `["title", "link"]`.
Пример:
```
{
  "menu": [{
    "item": "Golos",
    "dropdown_items": [
      [
        "Анонс Glasnost",
        "https://golos.io/ru--otkrytyij-kod/@glasnost/glasnost-v0-1-zapusk-open-sors-servera-dlya-prilozhenii-na-platforme-golos"
      ]
    ]
  }, {
    "item": "Steem",
    "dropdown_items": [
      [
        "Glasnost announcement",
        "http://glasnost.steempunks.com/authors/ontofractal/ann-introducing-glasnost-alpha-open-source-blog-and-app-server-for-steem-golos-blockchains"
      ]
    ]
  }],
}

```

## Настройки фильтров

В объектах `authors` должно присутстовать свойство `filters`, но свойства для индивидуальных фильтров могут отсутствовать.

Для фильтров тэгов и заглавий существует общее правило: сначала исключаются посты, которые не попадают в белый список, потом исключается посты, которые попадают в черный список.

### Пример фильтров

```
{
  "account_name": "ontofractal",
  "filters": {
    "tags": {
      "blacklist": ["ru--statistika"],
      "whitelist": []
    },
    "title": {
      "blacklist": [],
      "whitelist": ["Урок \\d"]
    },
    "created": {
      "only_after": "2017-01-01",
      "only_before": ""
    }
  }
}
```

### Настройка тегов

Теги должны быть указаны в транслитерированном формате: "ru--statistika", а не "статистика".

### Настройка даты публикации

Формат даты (без времени) должен использовать стандарт ISO 8601.

### Настройка заглавия

Строки в черном и белом списке должны быть валидными регулярными выражениями без открывающих и закрывающих `/`.


# Остановка докер контейнера Glasnost

`docker ps`

и найти имя контейнера `CONTAINER_NAME` (в колонке `NAMES`)

`docker stop CONTAINER_NAME`

`docker rm CONTAINER_NAME`
