<a id="top"></a>

<div align="center">

# GameSave.lua

***ЗАГРУЗОЧНЫЙ LUA-МОДУЛЬ,*** *написанный специально для игры [Ex Machina](https://store.steampowered.com/app/285500/Hard_Truck_Apocalypse__Ex_Machina/)*


***THE LOADING LUA-MODULE,*** *written specifically for the game [Hard Truck Apocalypse](https://store.steampowered.com/app/285500/Hard_Truck_Apocalypse__Ex_Machina/)*

**Lua 5.0**

<img src="exm_gamesave_logo.png" alt="exm_gamesave_logo_png" width="450" />

***

<table>
  <thead>
    <tr>
      <th style="text-align: center;">Содержание</th>
      <th style="text-align: center;">Table of contents (machine translation)</th>
    </tr>
  </thead>
  <tbody align="center">
    <tr>
      <td><a href="#wtf_ru">Краткое описание</a></td>
      <td><a href="#wtf_en">Brief description</a></td>
    </tr>
    <tr>
      <td><a href="#howToFixRelationship_ru">Как починить отношения группировок после бага (инструкция для игроков)</a></td>
      <td><a href="#howToFixRelationship_en">How to fix gangs relationship after a bug (instructions for players)</a></td>
    </tr>
   <tr>
      <td><a href="#whatCanThisLoad_ru">Что этот lua-модуль может загрузить</a></td>
      <td><a href="#whatCanThisLoad_en">What can this lua-module load</a></td>
    </tr>
    <tr>
      <td><a href="#howToLoadSaveFile_ru">Как загрузить сохранение через этот lua-модуль</a></td>
      <td><a href="#howToLoadSaveFile_en">How to load a save through this lua-module</a></td>
    </tr>
    <tr>
      <td><a href="#allAboutIt_ru">Все инструкции для моддеров</a></td>
      <td><a href="#allAboutIt_en">All instructions for modders</a></td>
    </tr>
    <tr>
      <td><a href="#allFunctions_ru">Все методы и функции</a></td>
      <td><a href="#allFunctions_en">All methods and functions</a></td>
    </tr>
    <tr>
      <td><a href="#incorrigibleBugs_ru">Неисправимые баги</a></td>
      <td><a href="#incorrigibleBugs_en">Incorrigible bugs</a></td>
    </tr>
    <tr>
      <td><a href="#detailsAndThanks_ru">Подробности и выражение благодарности</a></td>
      <td><a href="#detailsAndThanks_en">Details and gratitude</a></td>
    </tr>
  </tbody>
</table>

</div>

***

<a id="wtf_ru"></a>

## ЧТО ЭТО

Этот lua-модуль позволяет **ЗАГРУЗИТЬ** желаемое сохранение, **восстановить отношения группировок**, а также узнать информацию о игроке.

> Задача lua-модуля - попробовать помочь игрокам восстановить утерянный прогресс, а также как-то упростить работу участникам сообщества в создании модификаций, если им сложно реализовать что-то самостоятельно.

### ВОЗМОЖНОСТИ
- Загрузка любого желаемого сохранения!
- Восстановление испорченных отношений группировок после бага!
- Восстановление любого объекта из сохранения!
- Получение информации о игроке из сохранения!

<a id="howToFixRelationship_ru"></a>

### Инструкция для игроков, чтобы починить отношения группировок после бага. Это займет 5-10 минут:
*Может показаться сложно, но если вы далеко ушли с таким багом, это того стоит.*

1. После бага сделайте новое сохранение и выйдите из игры;

2. Скачайте [xmlparser.lua](https://github.com/ejetaxeblevich/XMLParser/releases/tag/260628a) и [gamesave.lua](https://github.com/ejetaxeblevich/GameSave/releases/tag/260723a) и поместите их в папку `data`;

3. Откройте текстовый файл `data/scripts/server.lua`;

4. Добавьте в самый низ следующий код:
```lua
XMLParser = require("data\\xmlparser.lua")
GS = require("data\\gamesave.lua")
```

5. Сохраните изменения.

**Теперь вам нужно выбрать один из двух вариантов восстановления отношений группировок:**

А. Для использования отношений по умолчанию, как при старте "новой игры" - введите в консоли `GS:LoadToleranceStatus()`

*или*

Б. Для возвращения отношений из старого сохранения, в котором они ещё работали корректно:

1. Запустите игру и загружайте сохранения по очереди от верхнего к нижнему, в процессе заглядывая в меню "Отношения". Вам нужно ближайшее сохранение, где отношения группировок к вам различаются (должны присутствовать и дружественные-зелёные, и вражеские-красные);

2. Запомните название исправного сохранения: например `Край Быстрое сохранение 2`;

3. Откройте папку `data/profiles/имя_вашего_профиля/saves` и найдите нужное сохранение по его названию (текстовые названия содержатся в файлах `saveinfo.xml` - вы можете воспользоваться "поиском по файлам" внутри вашего текстового редактора, чтобы не искать сейв вручную);

4. Запомните номер найденного сохранения (например `00000083`) и запишите его себе следующим образом: `GS:LoadToleranceStatus("data\\profiles\\имя_вашего_профиля\\saves\\00000083\\maps\\currentmap.xml")`

5. Загрузите ваше последнее сохранение (то, где отношения уже сломаны) и выполните во внутриигровой консоли код, что вы записали ранее (пункт 4).

> [!NOTE]
> **Консоль открывается клавишей `~` (`Ё`) при...**
> 
> А. ...запуске игры через *Community Mod Manager* с функцией "Включить консоль";
> 
> *или*
> 
> Б. ...прописывании `-console` в свойствах ярлыка игры, в поле "Объект" (`...hta.exe" -console`).

> [!WARNING]
> Такой способ не лишен бага: Если вы играете в мод, который где-то запрашивает статус отношений, вы можете словить **софтлок**. В таком случае вы все сделали зря и придется загружать раннее сохранение и проходить игру снова :)

<a id="allAboutIt_ru"></a><a href="#top">Наверх ↑</a>

## Ниже инструкции для моддеров!

> [!IMPORTANT]
> ***Для работы требует lua-модуль [XMLParser](https://github.com/ejetaxeblevich/XMLParser) версии `v1.2.2` и выше!***
>
> GameSave.lua должен запускаться после инициализации `XMLParser`, `g_ObjCont`, `g_QuestStateManager` и `g_Player`!


### Дисклеймер

АВТОР ЭТОГО ТВОРЕНИЯ ДУМАЕТ, ЧТО ЗНАЕТ, КАК ПРАВИЛЬНО НАЗЫВАТЬ И ИСПОЛЬЗОВАТЬ ВЕЩИ В ПРОГРАММИРОВАНИИ, ПОЭТОМУ ПРОСЬБА ДЛЯ ПРОГРАММИСТОВ ЗДОРОВОГО ЧЕЛОВЕКА - ПОНЯТЬ И ПРОСТИТЬ, ЕСЛИ ЗДЕСЬ ЧТО-ТО(ВСЕ) НЕ ТАК.


АВТОР ПОНИМАЕТ И ПРИНИМАЕТ, ЧТО ВЕСЬ КОД НИЖЕ И ЭТОТ ТЕКСТ НАПИСАН ПЛОХО, НЕПОНЯТНО И ГРОМОЗДКО, ЧТО ДАЖЕ В ЭТОМ ЗАНЯТИИ НЕТ НИ МАЛЕЙШЕГО СМЫСЛА - КАК И СМЫСЛА В ЭТОМ КАПСОМ НАПИСАННОМ ДИСКЛЕЙМЕРЕ.


LUA-МОДУЛЬ РАСПРОСТРАНЯЕТСЯ СВОБОДНО "КАК ЕСТЬ" И ИСПОЛЬЗУЕТСЯ ИГРОЙ EX MACHINA / HARD TRUCK APOCALYPSE И МОЖЕТ БЫТЬ ИЗМЕНЕН ЛЮБЫМ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ (МОДДЕРОМ) ВНУТРИ СВОИХ МОДИФИКАЦИЙ И ПРОЧИХ РЕСУРСАХ.

АВТОР НЕ НЕСЕТ ОТВЕТСТВЕННОСТИ ЗА КАКИЕ-ЛИБО ПОСЛЕДСТВИЯ, ПОВЛЕКШИХ ЗА СОБОЙ УЩЕРБ ВО ВРЕМЯ ИСПОЛЬЗОВАНИЯ ЭТОГО, А ТАКЖЕ ЛЮБОЙ ДРУГОЙ, В Т.Ч. ИЗМЕНЕННОЙ ВЕРСИИ LUA-МОДУЛЯ ИЛИ ЧАСТЕЙ КОДА, ПОЗАИМСТВОВАННЫХ (ПЕРЕПИСАННЫХ) ИЗ ЭТОГО ФАЙЛА.


## КАК ЭТО ИСПОЛЬЗОВАТЬ

Почему это "модуль", а не любой другой файл с lua-скриптами? Хотя он таким и является...
- Потому что этот файл - таблица функций GS (далее класс), который имеет свои собственные методы и функции, что очень похоже на серьезную тему. Наверное. Типа. Я хз...

### УСТАНОВКА

Для полноценного lua-модуля этой поделке еще далеко, поэтому ее не нужно устанавливать как библиотеку Lua в системе.

В игру этот lua-модуль может загружаться только через `require()`.
> [!CAUTION]
> Остальные способы **НЕ ПОДОЙДУТ**, так как необходимо сохранение параметров модуля.

Рекомендую прописывать команду в конец файла `server.lua` игры, поскольку могут использоваться в модуле команды, которые грузятся в игру чуть раньше сервера ("могут"? автор альцгеймер!).

В качестве аргумента функции указывается локальный путь до файла модуля.


Возвращаемая таблица помещается в глобальную переменную, которая будет использована как объект, на который будут применяться методы (функции) этого модуля через двоеточие. 

Чтобы было понятнее, вспомним как мы обращаемся к машине игрока: 
```lua
local Plv = GetPlayerVehicle()
if Plv then
    Plv:SetSkin(1)  --> метод на объект
end
```
Или к обжект контейнеру:
```lua
local Gde = CVector(1,2,3)
local Gde.y = g_ObjCont:GetHeight(Gde.x, Gde.z)  --> метод на объект
```

После загрузки модуля в игру уже можно начинать пользоваться его методами и глобальныим командами.

### Пример кода загрузки

```lua
--server.lua
GS = require("data\\gamedata\\lua_lib\\gamesave.lua")
if not GS then
    LOG("[E] Could not find global GameSave.lua...")
end
```

<a id="whatCanThisLoad_ru"></a><a href="#top">Наверх ↑</a>

## Что ВОЗМОЖНО ЗАГРУЗИТЬ на текущий момент
- \*Чистую карту;
- Машину игрока без визуальных повреждений;
- Инвентарь и гаджеты игрока, оружие с параметрами в виде ящика;
- Известные уровни на глобальной карте;
- Истории с датами, книги и энциклопедию в журнале;
- Квестовые предметы;
- Простые квесты *(могут быть баги с `ConditionToGive` и `OnEvents`)*;
- Сложные квесты *(могут быть баги с `SubQuestsCondition`, `ConditionToGive` и `OnEvents`)*;
- Отношения группировок;
- Погоду и время суток;
- Переменные карты SetVar;
- Активные триггеры (перезапускаются);
- Локации без активных ивентов и NPC;
- SpokenCount у NPC;
- Команды InfectionZones без сохранения таймеров зон;
- Команды машин и случайные машины без team с обновлением их путей следования;
- Humans с обновлением последнего пути следования;
- \*\*Аффиксы кабин и кузовов, свойства машин в мастерских;
- \*\*Аффиксы и цены пушек и гаджетов в магазинах;
- Статичные ящики с лутом;
- Поверхностно прочие неотсортированные объекты, в т.ч. breakable.

\* - игровой уровень, как он загружается в первый раз.

\*\* - необходима процедура в несколько шагов самим пользователем.


Все эти загрузки можно отдельно настроить в `LOADER CONFIG`.

## ТЕХНИКА БЕЗОПАСНОСТИ

- ***НАСТОЯТЕЛЬНО РЕКОМЕНДУЕТСЯ*** проверить настройки конфига модуля `LOADER CONFIG` в файле. Сравните с тем, что вы используете и что у вас установлено! Особое внимание стоит уделить различным спискам прототипов из игры в `Default_GamePrototypes`. Это очень важно, если модуль устанавливается поверх вашей модификации!

- ***ОБЯЗАТЕЛЬНО СЛЕДУЕТ*** произвести повторное сохранение на новый слот и его загрузку (сейвлоад) после "загрузки" игры с помощью этого модуля. Без этого происходит **TRIGGER ERROR** у триггеров с ивентами на изменение/смерть машины/объекта (и не только), хотя и применяются их имена на загрузке. Возможно игре не нравится новый объект с другим айди, но с тем же именем. Также это необходимо для последующего корректного выполнения `GS:LoadCached()` для подгрузки аффиксов в магазинах и прочего.

- ***НАСТОЯТЕЛЬНО РЕКОМЕНДУЕТСЯ*** ознакомиться с памяткой ниже `КАК ЗАГРУЗИТЬ СОХРАНЕНИЕ` для более полного понимания процедуры.

- ***ЗАПРЕЩАЕТСЯ*** активировать триггеры загружаемой карты через внешние скриптовые файлы на моменте загрузки сервера.

- Игра вполне может **вылететь** после "загрузки", если в моменте выбранного сохранения был бой, активная работа сторонних фич или тяжелых скриптов.

- Также не стоит полностью рассчитывать на возможности этого модуля и игры в трудную минуту для восстановления игрового прогресса. Ничего не может работать идеально, особенно в Махине. Если у вас все прекрасно загрузилось и не возникло вообще никаких багов - вы везунчик!

- ***ЗАПРЕЩАЕТСЯ*** использовать этот lua-модуль в своих модах без указания авторства. А то натравлю порчу и наколдую недельный понос 😡
*Шутка 💋*

<a id="allFunctions_ru"></a><a href="#top">Наверх ↑</a>

## ФУНКЦИИ И МЕТОДЫ

Здесь собраны все публичнные функции этого модуля. У каждой функции имеется детальное описание, что она делает и что в ней указывать. 

Для начала вам стоит ознакомиться как работает lua-модуль `XMLParser.lua`. Инструкция есть прямо в файле и на странице проекта на github. Это необходимо, если вы планируете изменять код здесь.

Модуль имеет некоторые функции и переменные В *ГЛОБАЛЬНОМ СКОУПЕ*, что может создавать перезапись уже существующих!!! Модуль также пытается использовать код из модификации ExplorerMod при загрузке и могут быть ошибки, если уже существующие одноименные вещи есть в вашем моде!

Список имен глобальных переменных, которые захватываются модулем (кроме lua-команд):

| Глобальное имя | Действие |
|-----------|-----------|
| `GameSaveFakeCoroutineScript` | Вызов функции GameSave.lua |
| `DoSomeByLoadingMap` | Безопасный вызов функции ExplorerMod |
| `GLOBAL_ITEMLIST` | Список ExplorerMod, иначе конфиг |
| `GLOBAL_NORMALVEHICLELIST` | Список ExplorerMod, иначе конфиг |
| `GLOBAL_VEHICLEPARTSLIST_BASKETS` | Список ExplorerMod, иначе конфиг |
| `GLOBAL_VEHICLEPARTSLIST_CABINS` | Список ExplorerMod, иначе конфиг |

Пожалуйста, не изменяйте область видимости локальных функций и методов с таблицами, и не пытайтесь использовать их по отдельности. Внутренние процессы GameSave выполняются в строго заданной последовательности и работают с "памятью" модуля, балансируя на нервах игры так, чтобы она старалась не вылетать. Это сделано в целях оптимизации кода: процессы Get и Set поделены игровой загрузкой, что немного облегчает выполнение кода. По крайней мере, так ожидает автор...

Редактируйте внутреннюю функцию `GameSave:LoadUserScript()` для своих нужд. Поместите в нее свой скрипт, который нужно выполнить сразу после загрузки сохранения. Используйте ее, как бы вы использовали server.lua или любой другой файл или триггер с GE_FRAMES_PASSED.

Некоторые методы возвращают table XMLParser-объекты. Юзердата не возвращается, поэтому для таких параметров как позиция и вращение необходимо уже самостоятельно парсить строку.

> [!IMPORTANT]
> **Обратите внимание**, что дочерний класс должен вызывать главный метод своего родительского класса вплоть до GS.

> [!TIP]
> Вы можете скроллить код ниже вправо и влево! Наведите курсор на полотно и колесиком мыши с помощью `shift` двигайте его!

```c
Class GS
{
   /* Загрузка сохранения */

   [M] void LoadGame( const char* SaveDirPATH )
   /* Загружает выбранное сохранение.

      Указывается путь до папки сохранения [SaveDirPATH], например:
      ["data\\profiles\\Player\\saves\\00000065"] */

   [M] void LoadCached()
   /* Загружает закэшированные динамические объекты,
      которые невозможно загрузить сразу с [LoadGame()]:

      аффиксы и цены в магазинах, прочее.

      Перед использованием сделайте [LoadGame()] и сейвлоад! */


   /* Восстановление отношений группировок */

   [M] int LoadToleranceStatus( const char* CustomPathToCurrentMap )
   /* Загружает отношения группировок из currentmap.xml желаемого сохранения.

   Загрузит отношения по умолчанию из relationship.xml, если [CustomPathToCurrentMap] = nil.

   Полезно, если у вас сломались отношения группировок - не нужно загружать ранние сейвы!
   Старое описание:
      --Чинит сломанные отношения после бага с RestoreAllToleranceStatus() когда все становятся мирными/врагами/хикками/моддерами. */

   [M] int LoadToleranceStatusBackup()
   /* Загружает сохраненные отношения группировок из tolerance.bak */

   [M] int SaveToleranceStatusBackup()
   /* Сохраняет текущие отношения группировок в tolerance.bak */


   /* Восстановление объекта */

   [M] AIParam CreateAndSetObjectFrom( const char* ObjectName, CVector NewPosition, const char* CustomPATHtoCurrentMap )
   /* Загружает любой объект из currentmap.xml желаемого сохранения, если это возможно.

      Объект появится в своей позиции, если [NewPosition] = nil.

      Загрузит объект из последнего сделанного/загруженного сохранения
      (сделайте [UpdateLastSavePATH("путь_к_сохранению")] либо [LoadGame()]),
      если [CustomPATHtoCurrentMap] = nil.

      Возвращает объект или статус */


   /* Получение и обновление информации о сохранениях */

   [M] tuple GetSaveFile( string ByLOGline )
   /* Возвращает имя и путь сохранения по совпадению внутри строки [ByLOGline] из exmachina.log */

   [M] tuple GetLoadedSaveName()
   /* Возвращает имя последнего загруженного сохранения и путь к нему */

   [M] tuple GetSavedFileName()
   /* Возвращает имя последнего сделанного сохранения и путь к нему */

   [M] void UpdateLastSavePATH( const char* PATH )
   /* Обновляет путь последнего сохранения для GameSave и GS */


   /* Переменные */

   [V] string LastSave_PATH
   /* Хранит путь к последнему файлу сохранения GameSave */


   /* Игрок из сохранения */

   [M] table GetPlayerFrom( const char* CustomPathToCurrentMap )
   /* Возвращает XMLParser-объект игрока из currentmap.xml желаемого сохранения */

   [M] AIParam GetFromSavedPlayer( const table xml_player, const char* CustomPATHtoCurrentMap, string ItemTag, string ItemProperty, string ItemPropertyValue, string PlayerProperty )
   /* Возвращает child или параметр [PlayerProperty] игрока из currentmap.xml желаемого сохранения.

      Укажите XMLParser-объект игрока [xml_player] для оптимизации кода,
      возьмет из сохранения [CustomPATHtoCurrentMap] снова, если [xml_player] = nil.

      Найдет child по [ItemTag], [ItemProperty] и [ItemPropertyValue].
      [PlayerProperty] может быть: "Money", "Belong" и т.п */

   [M] AIParam GetPlayerAttr( const table xml_player, const char* CustomPATHtoCurrentMap, string FindAttr )
   /* Возвращает параметр [FindAttr] игрока из currentmap.xml желаемого сохранения.

      Укажите XMLParser-объект игрока [xml_player] для оптимизации кода,
      возьмет из сохранения [CustomPATHtoCurrentMap] снова, если [xml_player] = nil.
      [FindAttr] может быть: "Money", "Belong" и т.п */


   /* Машина игрока из сохранения */
   Class PlayerVehicle
   {
      [M] PlayerVehicle GetPlayerVehicle( const table xml_player, const char* CustomPATHtoCurrentMap, string VehicleName ) : public GS
      /* Это прямое обращение к машине игрока.

         Укажите XMLParser-объект игрока [xml_player] для оптимизации кода,
         возьмет из сохранения [CustomPATHtoCurrentMap] снова, если [xml_player] = nil.
         [VehicleName] может быть nil */
      {
         [M] table GetRuntime()
         /* Возвращает XMLParser-объект содержимого Runtime машины */

         [M] table GetAllProperties()
         /* Возвращает все Property машины */

         [M] AIParam GetProperty( string PropertyName )
         /* Возвращает Property машины с именем [PropertyName]. Может быть числом или строкой */

         [M] table GetRepository()
         /* Возвращает XMLParser-объект содержимого Repository машины */

         [M] table GetRepositoryAsPrototypes()
         /* Возвращает содержимое инвентаря машины */

         [M] int GetRepositoryItemAmount( string ItemPrototype )
         /* Возвращает количество предметов с прототипом [ItemPrototype] инвентаря машины */

         [M] table GetParts()
         /* Возвращает XMLParser-объект содержимого Parts машины */

         [M] table GetPartByName( string PartName )
         /* Возвращает Part машины с именем [PartName] */

         [M] table GetGadgets()
         /* Возвращает все гаджеты машины */

         [M] table GetWheels()
         /* Возвращает все колеса машины */
      }
   }
}


/* Глобальная сервисная функция. По возможности не используйте */

[F] void GameSaveFakeCoroutineScript()
/* Выполняет "скрипт-корутину" для загрузчика GameSave */
```
<a id="howToLoadSaveFile_ru"></a><a href="#top">Наверх ↑</a>

## КАК ЗАГРУЗИТЬ СОХРАНЕНИЕ
0. Если вы можете в настоящем времени перезапустить игру - перезапустите ее. Пусть и вызывается очистка перед "загрузкой" сохранения, полная перезагрузка не помешает;
1. Выполните `GS:LoadGame("путь_к_папке_сохранения")` в консоли или внутри скрипта. Дождитесь успешного окончания загрузки. Если что-то ломается, исключите проблемный блок в `LOADER CONFIG`, перезапустите игру;
2. Сразу же, не посещая городов, ОБЯЗАТЕЛЬНО сохраните игру на новый слот и выполните его загрузку (сейвлоад);
3. Выполните `GS:LoadCached()` в консоли или внутри скрипта - для загрузки аффиксов в магазинах и прочего. Без п.2 это невозможно;
4. Еще раз сохраните игру на тот же слот и выполните его загрузку (сейвлоад) - от ошибок для пущего спокойствия.

<a id="incorrigibleBugs_ru"></a>

### Неизлечимые баги

- Дублирование историй и другого содержимого журнала при подгрузке квестов;
- Нестабильная обработка сложных квестов и дудос OnEvent'ами.

(я не придумал, как это можно починить)

<a id="detailsAndThanks_ru"></a>

## ПОДРОБНЕЕ

Эту и другую информацию вы сможете найти в файле проекта или найти примеры работы модуля в моде ExplorerMod от того же автора.

## КОММЕНТАРИИ АВТОРА

    E Jet: Это можно считать реверс инженерингом с помощью луашного яндередева?

## Благодарность 

- ***EmerEh*** за идею!
- ***Traygen*** за исправление формулировки инструкции <a href="#howToFixRelationship_ru">Как починить отношения группировок после бага (инструкция для игроков)</a>!

<a href="#top">Наверх ↑</a>

----

----

<a id="wtf_en"></a>

## WHAT IS IT

This lua module allows you to **LOAD** the desired save, **restore gangs relationships from bug**, and also find out information about the player.

>  The task of the lua module is to try to help players restore lost progress, as well as somehow simplify the work of community members in creating modifications if it is difficult for them to implement something on their own.

### FEATURES
- Loading any desired save!
- Restoring damaged groups relationship after a bug!
- Restore any object from save!
- Getting information about the player from the save!

<a id="howToFixRelationship_en"></a></a><a href="#top">Go up ↑</a>

### Instructions for players to fix group relationships after a bug. It will take 5-10 minutes:
*It may seem difficult, but if you have gone far in gameplay with this bug, it is worth it.*

1. After the bug, make a new save and exit the game;

2. Download [xmlparser.lua](https://github.com/ejetaxeblevich/XMLParser/releases/tag/260628a) and [gamesave.lua](https://github.com/ejetaxeblevich/GameSave/releases/tag/260723a) and place it in `data` game folder;

3. Open text game file `data/scripts/server.lua`;

4. Go to the bottom of the file and add this code:
```lua
XMLParser = require("data\\xmlparser.lua")
GS = require("data\\gamesave.lua")
```

5. Save the changes.

**Now you need to choose one of the two options for restoring the grouping relationship:**

A. To use the default relationship, as when starting a "new game", type `GS:LoadToleranceStatus()` in-game console.

*or*

B. To return the relationship from the old save file, in which they still worked correctly:

1. Start the game and load the saves one by one from the top to the bottom, while looking at the "Relationships" menu. You need a nearby save where the groups' attitudes towards you differ (both friendly-green and enemy-red must be present);

2. Remember the name of the correct save: for example, `Edge Quick save 2`;

3. Open the folder `data/profiles/your_profile_name/saves` and find the desired save by its name (the text names are contained in the files `saveinfo.xml ` you can use the "file search" inside your text editor to avoid searching for a save manually);

4. Remember the number of the found save (for example, `00000083`) and write it down to yourself as follows: `GS:LoadToleranceStatus("data\\profiles\\your_profile_name\\saves\\00000083\\maps\\currentmap.xml")`

5. Load your last save (the one where the relationship is already broken) and run the code in-game console that you wrote down earlier (point 4).

> [!NOTE]
> **The console opens with the `~` (<code>`</code>) key when...**
> 
> A. ...running the game through *Community Mod Manager* with the "Turn on Console" feature;
> 
> *or*
> 
> B. ...specifying `-console` in the properties of the game shortcut, in the "Object" field (`...hta.exe" -console`).

> [!WARNING]
> This method is not without a bug: If you are playing a mod that asks for relationship status somewhere, you can catch **softlock**. In this case, you did everything in vain and you will have to load the early save and play the game again :)

<a id="allAboutIt_en"></a><a href="#top">Go up ↑</a>

## Below are the instructions for modders!

> [!IMPORTANT]
> ***It requires the [XMLParser](https://github.com/ejetaxeblevich/XMLParser) lua-module version `v1.2.2` and higher!***
>
> GameSave.lua must be started after initialization `XMLParser`, `g_ObjCont`, `g_QuestStateManager` and `g_Player`!


### Disclaimer

THE AUTHOR OF THIS CREATION THINKS HE KNOWS HOW TO PROPERLY NAME AND USE THINGS IN PROGRAMMING, SO A REQUEST FOR HEALTHY PROGRAMMERS IS TO UNDERSTAND AND FORGIVE IF THERE IS SOMETHING (EVERYTHING) HERE NOT LIKE THAT.


THE AUTHOR UNDERSTANDS AND ACCEPTS THAT ALL THE CODE BELOW AND THIS TEXT IS POORLY WRITTEN, INCOMPREHENSIBLE AND CUMBERSOME, THAT EVEN THIS LESSON DOES NOT MAKE THE SLIGHTEST SENSE - AS WELL AS THE MEANING IN THIS CAPSULE DISCLAIMER.


THE LUA MODULE IS FREELY DISTRIBUTED "AS IS" AND IS USED BY THE GAME EX MACHINA / HARD TRUCK APOCALYPSE AND CAN BE MODIFIED BY ANY OTHER USER (MODDER) INSIDE THEIR OWN MODIFICATIONS AND OTHER RESOURCES.

THE AUTHOR IS NOT RESPONSIBLE FOR ANY CONSEQUENCES RESULTING IN DAMAGE DURING THE USE OF THIS, AS WELL AS ANY OTHER, INCLUDING MODIFIED VERSIONS OF THE LUA MODULE OR PARTS OF THE CODE BORROWED (REWRITTEN) FROM THIS FILE.


## HOW TO USE IT

Why is this a "module" and not any other lua script file? Although it is...
- Because this file is a GS function table (hereinafter referred to as a class), which has its own methods and functions, which is very similar to a serious topic. Probably. Like. I don't know...

### INSTALLATION

This craft is still far from being a full-fledged lua-module, so it does not need to be installed as a Lua library in the system.

This lua module can only be loaded into the game via `require()`.
> [!CAUTION]
> The other methods **WILL NOT WORK**, as it is necessary to save the module parameters.

I recommend writing the command at the end of the `server.lua` file of the game, since commands that are loaded into the game a little earlier than the server can be used in the module ("can"? the author is Alzheimer's!).

The local path to the module file is specified as the function argument.


The returned table is placed in a global variable, which will be used as an object to which the methods (functions) of this module will be applied separated by a colon. 

To make it clearer, let's recall how we refer to the player's car:
```lua
local Plv = GetPlayerVehicle()
if Plv then
    Plv:SetSkin(1)  --> method per object
end
```
Or object container:
```lua
local Gde = CVector(1,2,3)
local Gde.y = g_ObjCont:GetHeight(Gde.x, Gde.z)  --> method per object
```

After loading the module into the game, you can already start using its methods and global commands.

### Sample load code

```lua
--server.lua
GS = require("data\\gamedata\\lua_lib\\gamesave.lua")
if not GS then
    LOG("[E] Could not find global GameSave.lua...")
end
```

<a id="whatCanThisLoad_en"></a><a href="#top">Go up ↑</a>

## What is POSSIBLE to LOAD at the moment
- \*A blank level;
- The player's car without visual damage;
- Player's inventory and gadgets, weapons with parameters in the form of a loot box;
- Famous levels on the global map;
- Histories with dates, books, and an encyclopedia in a journal;
- Quest items;
- Simple quests *(there may be bugs with `ConditionToGive` and `OnEvents`)*;
- Difficult quests *(there may be bugs with `SubQuestsCondition`, `ConditionToGive` and `OnEvents`)*;
- Group relationships;
- Weather and time of day;
- SetVar map variables;
- Active triggers (restarting);
- Locations without active events and NPCs;
- NPC's SpokenCount;
- Infection Zones teams without saving zone timers;
- Teams of vehicles and random vehicles without a team with the update of their external paths;
- Humans with the update of the last external path;
- \*\*Affixes of cabs and baskets, properties of vehicles in workshops;
- \*\*Affixes and prices of guns and gadgets in shops;
- Static loot boxes;
- Superficially other unsorted objects, including breakable ones.

\* - The game level as it loads for the first time.

\*\* - requires a procedure in several steps by the user himself.


All these loads can be configured separately in the `LOADER CONFIG`.

## SAFETY PRECAUTIONS

- ***STRONGLY RECOMMENDED*** to check the configuration settings of the `LOADER CONFIG` module in the file. Compare with what you are using and what you have installed! Special attention should be paid to the various lists of prototypes from the game in `Default_GamePrototypes'. This is very important if the module is installed on top of your modification!

- ***BE SURE TO*** re-save to a new slot and load it (saveload) after "loading" the game using this module. Without this, **TRIGGER ERROR** occurs for triggers with events for changing/dying a machine/object (and not only), although their names are applied on loading. Maybe the game doesn't like the new object with a different ID, but with the same name. It is also necessary for the subsequent correct execution of `GS:LoadCached()` for loading affixes in stores and other things.

- ***STRONGLY RECOMMENDED*** to read the memo below `HOW TO LOAD A SAVE` for a more complete understanding of the procedure.

- ***FORBIDDEN*** to activate the triggers of the loaded map through external script files at the time of loading the server.

- The game may well **crash** after "loading" if there was a battle, active work of third-party features or heavy scripts at the time of the selected save.

- Also, you should not fully rely on the capabilities of this module and the game in difficult times to restore game progress. Nothing can work perfectly, especially in a this game. If everything has loaded perfectly and there are no bugs at all, you are lucky!

- ***FORBIDDEN*** to use this lua module in your mods without attribution. Otherwise, I'll set off a spell and conjure up a week's diarrhea.
*A joke 💋*

<a id="allFunctions_en"></a><a href="#top">Go up ↑</a>

## FUNCTIONS AND METHODS

All the public functions of this module are collected here. Each function has a detailed description of what it does and what to specify in it. 

First of all, you should familiarize yourself with how the lua-module `XMLParser.lua` works. The instructions are right in the file and on the project page on github. This is necessary if you plan to change the code here.

The module has some functions and variables in the GLOBAL SCOPE, which can create overwrites of existing ones!!! The module also tries to use the code from the ExplorerMod modification when loading, and there may be errors if existing items of the same name are in your mod!

List of names of global variables that are captured by the module (except for lua commands):

| Global name | Action |
|-----------|-----------|
| `GameSaveFakeCoroutineScript` | GameSave.lua function call |
| `DoSomeByLoadingMap` | Safe ExplorerMod function call |
| `GLOBAL_ITEMLIST` | The ExplorerMod list, otherwise the config |
| `GLOBAL_NORMALVEHICLELIST` | The ExplorerMod list, otherwise the config |
| `GLOBAL_VEHICLEPARTSLIST_BASKETS` | The ExplorerMod list, otherwise the config |
| `GLOBAL_VEHICLEPARTSLIST_CABINS` | The ExplorerMod list, otherwise the config |

Please do not change the scope of local functions and methods with tables, and do not try to use them separately. GameSave's internal processes run in a strictly defined sequence and work with the module's "memory", balancing on the nerves of the game so that it tries not to crash. This is done in order to optimize the code: the Get and Set processes are separated by game loading, which makes code execution a little easier. At least that's what the author expects...

Edit the internal `GameSave:LoadUserScript()` function for your needs. Put your script in it, which you need to execute immediately after loading the save. Use it as you would use server.lua or any other file or trigger with GE_FRAMES_PASSED.

Some methods return table XMLParser objects. User data is not returned, so for parameters such as position and rotation, you must parse the string yourself.

> [!IMPORTANT]
> That a child class must call the main method of its parent class up to GS.

> [!TIP]
> You can scroll the code below to the right and left! Hover the cursor over the canvas and use the mouse wheel to move it using `shift`!

```c
Class GS
{
   /* Load save */

   [M] void LoadGame( const char* SaveDirPATH )
   /* Loads the selected save.

      The path to the save folder [SaveDirPATH] is specified, for example:
      ["data\\profiles\\Player\\saves\\00000065"] */

   [M] void LoadCached()
   /* Loads cached dynamic objects that cannot be loaded immediately from [LoadGame()]:
      affixes and prices in stores, etc.

      Before using it, do [LoadGame()] and saveload! */


   /* Load gangs relationships */

   [M] int LoadToleranceStatus( const char* CustomPathToCurrentMap )
   /* Loads the relationships of gangs from currentmap.xml the desired preservation.

      Loads the default relationship from relationship.xml if [CustomPathToCurrentMap] = nil.
      It's useful if your gangs relationships are broken - you don't need to load early saves!
      Old description:
         --Fixes broken relationships after a bug with RestoreAllToleranceStatus() when everyone becomes peaceful/enemies/hicks/modders. */

   [M] int LoadToleranceStatusBackup()
   /* Loads saved gangs relationships from tolerance.bak */

   [M] int SaveToleranceStatusBackup()
   /* Saves saved gangs relationships to tolerance.bak */


   /* Load object */

   [M] AIParam CreateAndSetObjectFrom( const char* ObjectName, CVector NewPosition, const char* CustomPATHtoCurrentMap )
   /* Loads any object from currentmap.xml the desired preservation, if possible.

      The object will appear in its position if [newPosition] = nil.

      Loads the object from the last made/uploaded save
      (do [UpdateLastSavePATH("save_path")] or [LoadGame()])
      if [CustomPATHtoCurrentMap] = nil.

      Returns an object or status */


   /* Getting and updating information about saves */

   [M] tuple GetSaveFile( string ByLOGline )
   /* Returns the name and path of the save by coincidence inside the string [ByLOGline] from exmachina.log */

   [M] tuple GetLoadedSaveName()
   /* Returns the name of the last uploaded save and the path to it */

   [M] tuple GetSavedFileName()
   /* Returns the name of the last save made and the path to it */

   [M] void UpdateLastSavePATH( const char* PATH )
   /* Updates the last save path for GameSave and GS */


   /* Variables */

   [V] string LastSave_PATH
   /* Stores the path to the last save file GameSave */


   /* Player from save */

   [M] table GetPlayerFrom( const char* CustomPathToCurrentMap )
   /* Returns the XMLParser object of the player from currentmap.xml the desired save */

   [M] AIParam GetFromSavedPlayer( const table xml_player, const char* CustomPATHtoCurrentMap, string ItemTag, string ItemProperty, string ItemPropertyValue, string PlayerProperty )
   /* Returns the child or [PlayerProperty] parameter of the player from currentmap.xml the desired save.

      Specify the XMLParser object of the player [xml_player] to optimize the code,
      or it will take [CustomPATHtoCurrentMap] from the save again if [xml_player] = nil.

      It will find child by [ItemTag], [ItemProperty] and [ItemPropertyValue].
      [PlayerProperty] can be: "Money", "Belong", etc. */

   [M] AIParam GetPlayerAttr( const table xml_player, const char* CustomPATHtoCurrentMap, string FindAttr )
   /* Returns the [FindAttr] parameter of the player from currentmap.xml the desired save.

      Specify the XMLParser object of the player [xml_player] to optimize the code,
      or it will take [CustomPATHtoCurrentMap] from the save again if [xml_player] = nil.

      [FindAttr] can be: "Money", "Belong", etc. */


   /* Player vehicle from save */
   Class PlayerVehicle
   {
      [M] PlayerVehicle GetPlayerVehicle( const table xml_player, const char* CustomPATHtoCurrentMap, string VehicleName ) : public GS
      /* This is a direct appeal to the player's car.

         Specify the XMLParser object of the player [xml_player] to optimize the code,
         or it will take [CustomPATHtoCurrentMap] from the save again if [xml_player] = nil.
         [VehicleName] may be nil */
      {
         [M] table GetRuntime()
         /* Returns the XMLParser object of the Runtime vehicle content */

         [M] table GetAllProperties()
         /* Returns all the properties of the vehicle */

         [M] AIParam GetProperty( string PropertyName )
         /* Returns the Property of the vehicle with the name [propertyName]. It can be a number or a string */

         [M] table GetRepository()
         /* Returns the XMLParser object of the contents of the Repository of the vehicle */

         [M] table GetRepositoryAsPrototypes()
         /* Returns the contents of the vehicle inventory */

         [M] int GetRepositoryItemAmount( string ItemPrototype )
         /* Returns the number of items with the prototype [ItemPrototype] of the vehicle inventory */

         [M] table GetParts()
         /* Returns the XMLParser object of the Parts content of the vehicle */

         [M] table GetPartByName( string PartName )
         /* Returns the Part of the vehicle named [PartName] */

         [M] table GetGadgets()
         /* Returns all the gadgets of the vehicle */

         [M] table GetWheels()
         /* Returns all the wheels of the vehicle */
      }
   }
}


/* Global service function. If possible, do not use */

[F] void GameSaveFakeCoroutineScript()
/* Performs a "script coroutine" for the GameSave loader */
```
<a id="howToLoadSaveFile_en"></a><a href="#top">Go up ↑</a>

## HOW TO LOAD A SAVE
0. If you can restart the game in the present tense, restart it. Even if the cleanup is called before "loading" the save, a full reboot won't hurt;
1. Perform the `GS:LoadGame("path to the save folder")` in the console or inside the script. Wait for the load to finish successfully. If something breaks, eliminate the problematic block in the `LOADER CONFIG`, restart the game;
2. Immediately, without visiting cities, BE SURE to save the game to a new slot and load it (saveload);
3. Perform the `GS:LoadCached()` in the console or inside the script - for loading affixes in stores and other things. This is impossible without point 2;
4. Save the game to the same slot again and load it (saveload) to avoid errors for added peace of mind.

<a id="incorrigibleBugs_en"></a>

### Incurable bugs

- Duplication of stories and other magazine content when uploading quests;
- Unstable handling of complex quests and dudos OnEvents.

(I haven't figured out how to fix it)

<a id="detailsAndThanks_en"></a>

## LEARN MORE

You can find this and other information in the project file or find examples of how the module works in the ExplorerMod mod from the same author.

## AUTHOR'S COMMENTS

    E Jet: Can this be considered reverse engineering with lua yanderedev?

## Gratitude 

- ***EmerEh*** for the idea!
- ***Traygen*** for correcting the wording of the instruction <a href="#howToFixRelationship_en">How to fix gangs relationship after a bug (instructions for players)</a>!

<a href="#top">Go up ↑</a>
