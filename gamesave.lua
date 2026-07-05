-- ============================================================
-- ============================================================
-- 
-- 
--                  ЗАГРУЗОЧНЫЙ LUA-МОДУЛЬ,
-- 
--               написанный специально для игры
--             Ex Machina / Hard Truck Apocalypse
--
--                      GameSave v1.0
-- 
-- 
-- ===================== Автор E Jet ==========================
-- ============================================================
-- 
--     Note: Please translate this text, if it nessesary.
-- 
-- 
-- ======================= ЧТО ЭТО ============================
--
--
--      Этот lua-модуль позволяет ЗАГРУЗИТЬ желаемое сохранение, 
-- восстановить отношения группировок, а также узнать информацию 
-- о игроке.
--
--      Для работы требует lua-модуль XMLParser.lua версии v1.2.2
-- от того же автора: https://github.com/ejetaxeblevich
--      GameSave.lua должен запускаться после инициализации XMLParser,
-- g_ObjCont, g_QuestStateManager и g_Player!
-- 
--------- \/ Что ВОЗМОЖНО ЗАГРУЗИТЬ на текущий момент \/ -----------
--
--     - *Чистую карту;
--     - Машину игрока без визуальных повреждений;
--     - Инвентарь и гаджеты игрока, оружие с параметрами в виде ящика;
--     - Известные уровни на глобальной карте;
--     - Истории с датами, книги и энциклопедию в журнале;
--     - Квестовые предметы;
--     - Простые квесты (могут быть баги с ConditionToGive и OnEvents);
--     - Сложные квесты (могут быть баги с SubQuestsCondition, ConditionToGive и OnEvents);
--     - Отношения группировок;
--     - Погоду и время суток;
--     - Переменные карты SetVar;
--     - Активные триггеры (перезапускаются);
--     - Локации без активных ивентов и NPC;
--     - SpokenCount у NPC;
--     - Команды InfectionZones без сохранения таймеров зон;
--     - Команды машин и случайные машины без team с обновлением их путей следования;
--     - Humans с обновлением последнего пути следования;
--     - **Аффиксы кабин и кузовов, свойства машин в мастерских;
--     - **Аффиксы и цены пушек и гаджетов в магазинах;
--     - Статичные ящики с лутом;
--     - Поверхностно прочие неотсортированные объекты, в т.ч. breakable.
--
-- * - игровой уровень, как он загружается в первый раз.
-- ** - необходима процедура в несколько шагов самим пользователем.
--
-- Все эти загрузки можно отдельно настроить в LOADER CONFIG ниже.
--
------------------------------------------------------------
--
------------------------- Дисклеймер -----------------------
--
--      АВТОР ЭТОГО ТВОРЕНИЯ ДУМАЕТ, ЧТО ЗНАЕТ, КАК ПРАВИЛЬНО
-- НАЗЫВАТЬ И ИСПОЛЬЗОВАТЬ ВЕЩИ В ПРОГРАММИРОВАНИИ, ПОЭТОМУ 
-- ПРОСЬБА ДЛЯ ПРОГРАММИСТОВ ЗДОРОВОГО ЧЕЛОВЕКА - ПОНЯТЬ И 
-- ПРОСТИТЬ, ЕСЛИ ЗДЕСЬ ЧТО-ТО(ВСЕ) НЕ ТАК. 
--      АВТОР ПОНИМАЕТ И ПРИНИМАЕТ, ЧТО ВЕСЬ КОД НИЖЕ И ЭТОТ
-- ТЕКСТ НАПИСАН ПЛОХО, НЕПОНЯТНО И ГРОМОЗДКО, ЧТО ДАЖЕ В ЭТОМ
-- ЗАНЯТИИ НЕТ НИ МАЛЕЙШЕГО СМЫСЛА - КАК И СМЫСЛА В ЭТОМ КАПСОМ 
-- НАПИСАННОМ ДИСКЛЕЙМЕРЕ.
--
--      LUA-МОДУЛЬ РАСПРОСТРАНЯЕТСЯ СВОБОДНО "КАК ЕСТЬ" И 
-- ИСПОЛЬЗУЕТСЯ ИГРОЙ EX MACHINA / HARD TRUCK APOCALYPSE И МОЖЕТ 
-- БЫТЬ ИЗМЕНЕН ЛЮБЫМ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ (МОДДЕРОМ) ВНУТРИ СВОИХ 
-- МОДИФИКАЦИЙ И ПРОЧИХ РЕСУРСАХ.
--      АВТОР НЕ НЕСЕТ ОТВЕТСТВЕННОСТИ ЗА КАКИЕ-ЛИБО ПОСЛЕДСТВИЯ, 
-- ПОВЛЕКШИХ ЗА СОБОЙ УЩЕРБ ВО ВРЕМЯ ИСПОЛЬЗОВАНИЯ ЭТОГО, А
-- ТАКЖЕ ЛЮБОЙ ДРУГОЙ, В Т.Ч. ИЗМЕНЕННОЙ ВЕРСИИ LUA-МОДУЛЯ ИЛИ
-- ЧАСТЕЙ КОДА, ПОЗАИМСТВОВАННЫХ (ПЕРЕПИСАННЫХ) ИЗ ЭТОГО ФАЙЛА.
-- 
---------------------------------------------------------------
--
-- ============================================================
--
-- ================= КАК ЭТО ИСПОЛЬЗОВАТЬ =====================
-- 
-- 
--      Для полноценного lua-модуля этой поделке еще далеко, 
-- поэтому ее не нужно устанавливать как lua-библиотеку в системе.
-- 
--      В игру этот lua-модуль может загружаться только через 
-- [require()]. Остальные способы НЕ ПОДОЙДУТ, так как необходимо
-- сохранение параметров модуля.
--
--      Рекомендую прописывать команду в конец файла server.lua
-- игры, поскольку могут использоваться в модуле команды, которые 
-- грузятся в игру чуть раньше сервера ("могут"? автор альцгеймер!).
--
--      В качестве аргумента функции указывается локальный путь до 
-- файла модуля.
--      Инициализируемая таблица помещается в глобальную переменную, 
-- которая будет использована как объект, на который будут 
-- применяться методы (функции) этого модуля через двоеточие. 
--
-- Чтобы было понятнее, вспомним как мы обращаемся к машине игрока:
-- 
-- lua
-- [[
--      local Plv = GetPlayerVehicle()
--      if Plv then
--          Plv:SetSkin(1)  --> метод на объект
--      end
-- ]]
--
-- Или к обжект контейнеру:
--
-- lua
-- [[
--      local Gde = CVector(1,2,3)
--      local Gde.y = g_ObjCont:GetHeight(Gde.x, Gde.z)  --> метод на объект
-- ]]
-- 
--      После загрузки модуля в игру уже можно начинать пользоваться его
-- методами и глобальныим командами.
--
-----------------------------------------------------------------
--
----------------- \/ Пример кода загрузки \/ --------------------
--
-- lua
-- [[
--     GS = require("data\\gamedata\\lua_lib\\gamesave.lua")
--     if not GS then
--         LOG("[E] Could not find global GameSave.lua...")
--     end
-- ]]
--
---------------------------------------------------------------
--
-- ================= ТЕХНИКА БЕЗОПАСНОСТИ =====================
--
--
--      НАСТОЯТЕЛЬНО РЕКОМЕНДУЕТСЯ проверить настройки конфига
-- модуля LOADER CONFIG в этом файле. Сравните с тем, что вы
-- используете и что у вас установлено!
--      Особое внимание стоит уделить различным спискам прототипов
-- из игры в [Default_GamePrototypes]. Это очень важно, если
-- модуль устанавливается поверх вашей модификации!
--
--      ОБЯЗАТЕЛЬНО СЛЕДУЕТ произвести повторное сохранение на
-- новый слот и его загрузку (сейвлоад) после "загрузки" игры с
-- помощью этого модуля.
--      Без этого происходит TRIGGER ERROR у триггеров с ивентами
-- на изменение/смерть машины/объекта (и не только), хотя и 
-- применяются их имена на загрузке. Возможно игре не нравится новый 
-- объект с другим айди, но с тем же именем.
--      Также это необходимо для последующего корректного выполнения
-- [GS:LoadCached()] для подгрузки аффиксов в магазинах и прочего.
--
--      НАСТОЯТЕЛЬНО РЕКОМЕНДУЕТСЯ ознакомиться с памяткой ниже
-- [КАК ЗАГРУЗИТЬ СОХРАНЕНИЕ] для более полного понимания процедуры.
--
--      ЗАПРЕЩАЕТСЯ активировать триггеры загружаемой карты через
-- внешние скриптовые файлы на моменте загрузки сервера.
--
--      Игра вполне может вылететь после "загрузки", если в моменте
-- выбранного сохранения был бой, активная работа сторонних фич или
-- тяжелых скриптов.
--
--      Также не стоит полностью рассчитывать на возможности этого
-- модуля и игры в трудную минуту для восстановления игрового
-- прогресса. Ничего не может работать идеально, особенно в Махине.
--      Если у вас все прекрасно загрузилось и не возникло вообще
-- никаких багов - вы везунчик!
--
--      ЗАПРЕЩАЕТСЯ использовать этот lua-модуль в своих модах
-- без указания авторства.
--      А то натравлю порчу и наколдую недельный понос >:(
--      Шутка :*
--
---------------------------------------------------------------
--
-- =================== ФУНКЦИИ И МЕТОДЫ =======================
--
--
--      Здесь собраны все публичнные функции этого модуля. У 
-- каждой функции имеется детальное описание, что она делает и
-- что в ней указывать.
--
--      Для начала вам стоит ознакомиться как работает lua-модуль 
-- XMLParser.lua. Инструкция есть прямо в файле и на странице
-- проекта на github. Это необходимо, если вы планируете изменять
-- код здесь.
--
--      Модуль имеет некоторые функции и переменные В ГЛОБАЛЬНОМ 
-- СКОУПЕ, что может создавать перезапись уже существующих!!!
--      Модуль также пытается использовать код из модификации 
-- ExplorerMod при загрузке и могут быть ошибки, если уже существующие 
-- одноименные вещи есть в вашем моде!
--      Список имен глобальных переменных, которые захватываются модулем
--  (кроме lua-команд):
--      - [GameSaveFakeCoroutineScript] - вызов функции GameSave.lua;
--      - [DoSomeByLoadingMap] - безопасный вызов функции ExplorerMod;
--      - [GLOBAL_ITEMLIST] - список ExplorerMod, иначе конфиг;
--      - [GLOBAL_NORMALVEHICLELIST] - список ExplorerMod, иначе конфиг;
--      - [GLOBAL_VEHICLEPARTSLIST_BASKETS] - список ExplorerMod, иначе конфиг;
--      - [GLOBAL_VEHICLEPARTSLIST_CABINS] - список ExplorerMod, иначе конфиг.
--
--      Пожалуйста, не изменяйте область видимости локальных 
-- функций и методов с таблицами, и не пытайтесь использовать их 
-- по отдельности. Внутренние процессы GameSave выполняются в 
-- строго заданной последовательности и работают с "памятью" модуля,
-- балансируя на нервах игры так, чтобы она старалась не вылетать.
--      Это сделано в целях оптимизации кода: процессы Get и Set 
-- поделены игровой загрузкой, что немного облегчает выполнение 
-- кода. По крайней мере, так ожидает автор...
--
--      Редактируйте внутреннюю функцию [GameSave:LoadUserScript()]
-- для своих нужд.
--      Поместите в нее свой скрипт, который нужно выполнить сразу 
-- после загрузки сохранения. Используйте ее, как бы вы использовали 
-- server.lua или любой другой файл или триггер с GE_FRAMES_PASSED.
--
--      Некоторые методы возвращают table XMLParser-объекты.
--      Юзердата не возвращается, поэтому для таких параметров как 
-- позиция и вращение необходимо уже самостоятельно парсить строку.
--
--      Обратите внимание, что дочерний класс должен вызывать 
-- главный метод своего родительского класса вплоть до GS.
--
---------------------------------------------------------------
--
-- c
-- [[
--    Class GS
--    {
--        /* Загрузка сохранения */
--        [M] void LoadGame( const char* SaveDirPATH )   /* Загружает выбранное сохранение. Указывается путь до папки сохранения [SaveDirPATH], например: ["data\\profiles\\Player\\saves\\00000065"] */
--        [M] void LoadCached()   /* Загружает закэшированные динамические объекты, которые невозможно загрузить сразу с [LoadGame()]: аффиксы и цены в магазинах, прочее. Перед использованием сделайте [LoadGame()] и сейвлоад! */
--
--        /* Восстановление отношений группировок */
--        [M] int LoadToleranceStatus( const char* CustomPathToCurrentMap )   /* Загружает отношения группировок из currentmap.xml желаемого сохранения. Загрузит отношения по умолчанию из relationship.xml, если [CustomPathToCurrentMap] = nil. Полезно, если у вас сломались отношения группировок - не нужно загружать ранние сейвы! Старое описание: --Чинит сломанные отношения после бага с RestoreAllToleranceStatus() когда все становятся мирными/врагами/хикками/моддерами. */
--        [M] int LoadToleranceStatusBackup()       /* Загружает сохраненные отношения группировок из tolerance.bak */
--        [M] int SaveToleranceStatusBackup()       /* Сохраняет текущие отношения группировок в tolerance.bak */
--
--        /* Восстановление объекта */
--        [M] AIParam CreateAndSetObjectFrom( const char* ObjectName, CVector NewPosition, const char* CustomPATHtoCurrentMap )     /* Загружает любой объект из currentmap.xml желаемого сохранения, если это возможно. Объект появится в своей позиции, если [NewPosition] = nil. Загрузит объект из последнего сделанного/загруженного сохранения (сделайте [UpdateLastSavePATH("путь_к_сохранению")] либо [LoadGame()]), если [CustomPATHtoCurrentMap] = nil. Возвращает объект или статус */
--
--        /* Получение и обновление информации о сохранениях */
--        [M] tuple GetSaveFile( string ByLOGline )    /* Возвращает имя и путь сохранения по совпадению внутри строки [ByLOGline] из exmachina.log */
--        [M] tuple GetLoadedSaveName()    /* Возвращает имя последнего загруженного сохранения и путь к нему */
--        [M] tuple GetSavedFileName()     /* Возвращает имя последнего сделанного сохранения и путь к нему */
--        [M] void UpdateLastSavePATH( const char* PATH )   /* Обновляет путь последнего сохранения для GameSave и GS */
--
--        /* Переменные */
--        [V] string LastSave_PATH     /* Хранит путь к последнему файлу сохранения GameSave */
--
--        /* Игрок из сохранения */
--        [M] table GetPlayerFrom( const char* CustomPathToCurrentMap )     /* Возвращает XMLParser-объект игрока из currentmap.xml желаемого сохранения */
--        [M] AIParam GetFromSavedPlayer( const table xml_player, const char* CustomPATHtoCurrentMap, string ItemTag, string ItemProperty, string ItemPropertyValue, string PlayerProperty )		/* Возвращает child или параметр [PlayerProperty] игрока из currentmap.xml желаемого сохранения. Укажите XMLParser-объект игрока [xml_player] для оптимизации кода, возьмет из сохранения [CustomPATHtoCurrentMap] снова, если [xml_player] = nil. Найдет child по [ItemTag], [ItemProperty] и [ItemPropertyValue]. [PlayerProperty] может быть: "Money", "Belong" и т.п */
--        [M] AIParam GetPlayerAttr( const table xml_player, const char* CustomPATHtoCurrentMap, string FindAttr )    /* Возвращает параметр [FindAttr] игрока из currentmap.xml желаемого сохранения. Укажите XMLParser-объект игрока [xml_player] для оптимизации кода, возьмет из сохранения [CustomPATHtoCurrentMap] снова, если [xml_player] = nil. [FindAttr] может быть: "Money", "Belong" и т.п */
--
--        /* Машина игрока из сохранения */
--        Class PlayerVehicle
--        {
--            [M] PlayerVehicle GetPlayerVehicle( const table xml_player, const char* CustomPATHtoCurrentMap, string VehicleName ) : public GS     /* Это прямое обращение к машине игрока. Укажите XMLParser-объект игрока [xml_player] для оптимизации кода, возьмет из сохранения [CustomPATHtoCurrentMap] снова, если [xml_player] = nil. [VehicleName] может быть nil */
--            {
--                [M] table GetRuntime()    /* Возвращает XMLParser-объект содержимого Runtime машины */
--                [M] table GetAllProperties()    /* Возвращает все Property машины */
--                [M] AIParam GetProperty( string PropertyName )     /* Возвращает Property машины с именем [PropertyName]. Может быть числом или строкой */
--                [M] table GetRepository()       /* Возвращает XMLParser-объект содержимого Repository машины */
--                [M] table GetRepositoryAsPrototypes()    /* Возвращает содержимое инвентаря машины */
--                [M] int GetRepositoryItemAmount( string ItemPrototype )      /* Возвращает количество предметов с прототипом [ItemPrototype] инвентаря машины */
--                [M] table GetParts()      /* Возвращает XMLParser-объект содержимого Parts машины */
--                [M] table GetPartByName( string PartName )     /* Возвращает Part машины с именем [PartName] */
--                [M] table GetGadgets()    /* Возвращает все гаджеты машины */
--                [M] table GetWheels()     /* Возвращает все колеса машины */
--            }
--        }
--    }
--
--    /* Глобальная сервисная функция. По возможности не используйте */
--    [F] void GameSaveFakeCoroutineScript()      /* Выполняет "скрипт-корутину" для загрузчика GameSave */
--
-- ]]
--
---------------------------------------------------------------
--
-- ================= КАК ЗАГРУЗИТЬ СОХРАНЕНИЕ =================
--
-- 0. Если вы можете в настоящем времени перезапустить игру - перезапустите ее. Пусть и вызывается очистка перед "загрузкой" сохранения, полная перезагрузка не помешает;
-- 1. Выполните [GS:LoadGame("путь_к_папке_сохранения")] в консоли или внутри скрипта. Дождитесь успешного окончания загрузки. Если что-то ломается, исключите проблемный блок в LOADER CONFIG, перезапустите игру;
-- 2. Сразу же, не посещая городов, ОБЯЗАТЕЛЬНО сохраните игру на новый слот и выполните его загрузку (сейвлоад);
-- 3. Выполните [GS:LoadCached()] в консоли или внутри скрипта - для загрузки аффиксов в магазинах и прочего. Без п.2 это невозможно;
-- 4. Еще раз сохраните игру на тот же слот и выполните его загрузку (сейвлоад) - от ошибок для пущего спокойствия.
--
-- ============================================================
--
------------------ \/ Неизлечимые баги \/ ---------------------
--
-- > Дублирование историй и другого содержимого журнала при подгрузке квестов;
-- > Нестабильная обработка сложных квестов и дудос OnEvent'ами.
--
-- (я не придумал, как это можно починить)
--
---------------------------------------------------------------
--
-- ======================= ПОДРОБНЕЕ ==========================
--
--
--      Эту и другую информацию вы сможете найти на github  
-- проекта или найти примеры работы парсера в моде ExplorerMod 
-- от того же автора.
--      Ссылка на github: https://github.com/ejetaxeblevich
--
---------------------------------------------------------------
--
-- =================== КОММЕНТАРИИ АВТОРА =====================
-- 
-- E Jet: Это можно считать реверс инженерингом с помощью луашного яндередева?
-- 
-- ============================================================
-- ============================================================



-- //////////////////////////// MODULE INIT /////////////////////////////////


local GameSave = {}
GameSave.__index = GameSave
GameSave.version = "v1.0"
GameSave.LastSave_PATH = nil
GameSave.cfg = {}
GameSave.File = {}
GameSave.File.SaveInfo = {}
GameSave.File.CurrentMap = {}
GameSave.File.WeatherDetail = {}
GameSave.File.Triggers = {}
GameSave.File.CinemaTriggers = {}
GameSave.File.ExternalPaths = {}
GameSave.File.Quests = {}

local File = GameSave.File
local SaveInfo = GameSave.File.SaveInfo
local CurrentMap = GameSave.File.CurrentMap
local WeatherDetail = GameSave.File.WeatherDetail
local Triggers = GameSave.File.Triggers
local CinemaTriggers = GameSave.File.CinemaTriggers
local ExternalPaths = GameSave.File.ExternalPaths
local Quests = GameSave.File.Quests
local CONFIG = GameSave.cfg


local str_find = string.find
local str_sub = string.sub
local str_gsub = string.gsub
local str_len = string.len

local t_insert = table.insert
local t_concat = table.concat
local t_getn = table.getn
local t_sort = table.sort

local io_open = io.open


LOG("[I] Init Module GameSave.lua ...")


if not XMLParser then
    LOG("[E] Module GameSave.lua === XMLParser not found!!!")
    return nil
end

if not g_ObjCont then
    LOG("[E] Module GameSave.lua === g_ObjCont not found!!!")
    return nil
end
if not g_QuestStateManager then
    LOG("[E] Module GameSave.lua === g_QuestStateManager not found!!!")
    return nil
end


-- //////////////////////////// LOADER CONFIG ///////////////////////////////


--Конфигурация загрузки. Измените, если загрузки происходят с ошибками, а также, пожалуйста, отправьте багрепорт
CONFIG.Player_LoadMoney = true
CONFIG.Player_LoadVehicle = true
CONFIG.Player_LoadInventory = true		--> Работает вместе с Player_LoadVehicle
CONFIG.Player_LoadGadgets = true		--> Работает вместе с Player_LoadVehicle
CONFIG.GUI_LoadRadar = true
CONFIG.GUI_LoadLevels = true
CONFIG.GUI_LoadHistory = true
CONFIG.GUI_LoadBooks = true
CONFIG.GUI_LoadEncyclopaedia = true
CONFIG.GUI_LoadQuestItems = true
CONFIG.GUI_LoadToleranceStatus = true
CONFIG.LoadQuestState = true
-- CONFIG.QuestState_LoadSimpleQuests = true		--> (отсоединено) Работает вместе с LoadQuestState
-- CONFIG.QuestState_LoadDifficultQuests = true 	--> (отсоединено) Работает вместе с LoadQuestState
CONFIG.LoadWeatherState = true
CONFIG.Script_LoadTriggers = true
CONFIG.Script_LoadVars = true		--> Работает вместе с Script_LoadTriggers
CONFIG.DynamicScene_LoadInfection = true
CONFIG.DynamicScene_LoadLocations = true
CONFIG.DynamicScene_LoadTeams = true
CONFIG.DynamicScene_LoadTowns = true
CONFIG.DynamicScene_LoadVehicles = true
CONFIG.DynamicScene_LoadVehicles_ExternalPaths = true
CONFIG.DynamicScene_LoadBarricades = true
CONFIG.DynamicScene_LoadHumans = true
CONFIG.DynamicScene_LoadDots = true
CONFIG.DynamicScene_LoadChests = true
CONFIG.DynamicScene_LoadNPCsSpokenCounts = true
CONFIG.DynamicScene_LoadUnsortedObjects = true      --> Любые другие объекты, которые имеют имена, в т.ч. breakable

--Списки стандартных прототипов оригинальной игры и Community Patch 1.14 (некоторые могут быть из ExplorerMod, не влияет)
--Пожалуйста, ВПИШИТЕ СЮДА НОВЫЕ ПРОТОТИПЫ которые добавляет ваша модификация, иначе будут ошибки при загрузке городов!
CONFIG.Default_GamePrototypes_Item = {"potato","scrap_metal","firewood","oil","bottle","fuel","machinery","tobacco","book","electronics","quest_start_father_letter","quest_potato","quest_medicine_box","quest_explosive","quest_wine_barrels","quest_komp_splav","quest_shaman_head1","quest_shaman_head2","quest_old_digital","quest_art_masterpice","quest_mafia_narcotik","quest_first_canistra","quest_disk_1","quest_disk_2","quest_key_for_submarine","quest_key_for_tunnel","quest_monster_head","quest_magic_thing1","quest_magic_thing2","quest_explosion_stone","quest_repair_robot1","quest_repair_robot2","quest_repair_robot3","someTurboAccelerationPusher","engineOilPusher","nailsPusher","Smoke","minePusher","minePusher_1","minePusher_2","hornet01","specter01","pkt01","kord01","maxim01","storm01","fagot01","rapier01","vector01","vulcan01","flag01","kpvt01","rainmetal01","elephant01","odin01","bumblebee01","omega01","tank01","cyclops01","robotgun01","hammer01","octopus01","hail01R","hail01L","hailSideGun","mars01R","mars01L","marsSideGun","zeus01R","zeus01L","zeusSideGun","hunter01L","hunter01R","hunterSideGun","anti_missile_system","cooling_system_guns","cooling_system_energy","cooling_system_explosion","firing_rate_guns","firing_rate_energy","grouping_angle_guns","add_damage_guns","add_damage_energy","add_damage_explosion","firing_range_guns","cooling_system_guns2","cooling_system_energy2","cooling_system_explosion2","firing_rate_guns2","firing_rate_energy2","grouping_angle_guns2","add_damage_guns2","add_damage_energy2","add_damage_explosion2","cooling_system_guns_and_firing_rate_guns","cooling_system_energy_and_firing_rate_energy","cooling_system_explosion_and_firing_rate_explosion","firing_rate_guns_and_add_damage_guns","firing_rate_energy_and_add_damage_energy","firing_rate_explosion_and_add_damage_explosion","add_damage_guns_and_grouping_angle_guns","add_damage_energy_and_firing_rate_energy","add_damage_explosion_firing_rate_explosion","additional_fuel_tank","additional_torque","additional_durability","additional_stability","additional_fuel_tank2","additional_torque2","additional_durability2","add_speed_and_torque","add_stability_and_speed","add_torque_and_stability","additional_fuel_tank2_add_damage_guns"}
CONFIG.Default_GamePrototypes_Cabin = {"robot01Cab01","robot01Cab02","robot01Cab03","robot02Cab01","sml1Cab01","sml2Cab01","FormulaCab01","sml3Cab01","sml4Cab01","arcadescoutCab","denscoutCab","scoutCab01","scoutCab02","scoutCabMenu","scoutCab03","fighterCab01","fighterCab02","fighterCabMenu","hunterCab01","hunterCab02","cruiserCab01","cruiserCab02","dozerCab01","bugCab01","bugCab02","bugCab03","molokovozCab01","molokovozCab02","molokovozCabMenu","molokovozCab03","uralCab01","uralCab02","uralCab03","uralCab04","uralCab05","uralCabMenu","belazCab01","belazCab02","belazCabMenu","belazCab03","belazCab04","belazCab05","mirotvorecCab01","mirotvorecCab02","mirotvorecCab03","mirotvorecCab04","mirotvorecCab05"}
CONFIG.Default_GamePrototypes_Cargo = {"fakeCargo","dozerCargo01","bigfakeCargo","cruiserCargo01","cruiserCargo02","bugCargo01","bugCargo02","bugCargo03","molokovozCargo01","molokovozCargo02","molokovozCargo03","e_molokovozCargo01","e_molokovozCargo02","e_molokovozCargo03","molokovozCargo04","molokovozTrailer01Basket","uralCargo01","uralCargo02","uralCargo03","uralCargo04","uralCargo05","e_uralCargo01","e_uralCargo02","e_uralCargo03","e_uralCargo04","e_uralCargo05","belazCargo01","belazCargo02","belazCargo03","belazCargo04","belazCargo05","mirotvorecCargo01","mirotvorecCargo02","mirotvorecCargo03","mirotvorecCargo04","mirotvorecCargo05"}
CONFIG.Default_GamePrototypes_Vehicle = {"Robot02","Robot01","Sml4","Sml3","Sml2","Sml1","Sml1EnemySpawn","Sml2EnemySpawn","Sml3EnemySpawn","Sml4EnemySpawn","Scout","ScoutEnemySpawn","ArcadeScout","DenScout","Fighter","FighterEnemySpawn","Hunter","HunterEnemySpawn","Cruiser","CruiserEnemySpawn","Dozer","DozerEnemySpawn","Tank","Bug","Molokovoz","MolokovozTrailer","Ural","Belaz","Mirotvorec","r1m1_scout01","r1m1_scout02","r1m1_scout03","r1m3_MerScout","r1m1_molokovoz01","r1m1_molokovoz02","r1m1_molokovoz03","r1m1_bug01","r1m1_bug02","r1m1_bug03","r1m2_bug04","r1m1_sml01","r1m1_sml02","r1m1_sml03","r1m1_sml04","r1m2_hunter02","r1m3_hunter02","Scout01","Scout02","Scout03","ArcadeScout01","Fighter01","Fighter02","Fighter03","Hunter01","Hunter02","Cruiser01","Cruiser02","Dozer01","Traktor01","Tank01","Bug01","Bug02","Bug03","Molokovoz00","Molokovoz01","Molokovoz02","Molokovoz03","Ural00","Ural01","Ural02","Ural03","Belaz01","Belaz02","Belaz03","Mirotvorec01","Mirotvorec02","Mirotvorec03","CoolBelaz_2","CoolBelaz","ArcadeBelaz","DemoBandit","PublicDemoBug01","PublicDemoSinks","PublicDemoBandit1","PublicDemoBandit2","PublicDemoFighter","PublicDemoIeriBand1","PublicDemoIeriBand2","PublicDemoIeriCar","LisaCar","FelixVehicle","FelixVehicle2","AxelVehicle","DemoFighter1","DemoHunter1","DemoHunter2","DemoBug1","DemoBug2","DemoBug3","DemoMolokovoz1","DemoMolokovoz2","DemoMolokovoz3","DemoUral1","DemoShot1","DemoUral2","DemoUral3","DemoBelaz1","DemoBelaz2","DemoBelaz3","DemoMirotvorec1","DemoMirotvorec2","DemoMirotvorec3","Revolutioner1","Revolutioner2","BelazTest","MolokovozTest","Sml101","Sml201","Sml301","Sml401","mirotvorecTest","mirotvorecTest1","MirotvorecForSale","BugTest1","BelazTest01","BelazTest02","BelazTest03","BelazTest04","BelazTest05","BelazForSale","BugForSale","UralForSale","MolokovozForSale","BelazShot","UralShot","MirotvorecShot","Formula","Formula01","r1m3_Fighter01","r1m3_Fighter02","r1m3_Sml101","r1m3_molokovoz03","r1m3_molokovozInOldCity","r2m1_Bug1","r2m1_Fighter01","r2m1_Fighter02","r2m1_FighterGulik","r2m1_FighterNarcCaravan","r2m1_Hunter01","r2m1_Hunter02","r2m1_HunterNarcCaravan","r2m1_HunterNarcBoss","r2m1_Ural01","r2m1_Belaz01","r2m1_Molokovoz01","r2m1_scout01","r2m1_scout02","r2m1_scout03","r2m2_Molokovoz01","r2m2_Fighter01","r2m2_Fighter02","r2m2_Hunter01","r2m2_scout01","r2m2_Ural01","RobotBobot01","RobotBobot02","RobotTron","RobotMetatron","r2m2_ShamanHunter01","r2m2_ShamanHunter02","r1m1_CaravanBug01","r1m1_CaravanBug02","r1m1_CaravanBug03","r1m1_CaravanBug04","r1m2_CaravanBug01","r1m2_CaravanBug02","r1m3_CaravanMolokovoz01","r1m3_CaravanMolokovoz02","r2m1_CaravanMolokovoz01","r2m1_CaravanMolokovoz02","r2m1_CaravanUral01","r2m1_CaravanUral02","r2m2_CaravanUral01","r2m2_CaravanUral02","UralMenu","BelazMenu","MolokovozMenu","ScoutMenu","r1m1_CaravanGuardianSml101","r1m1_CaravanGuardianSml201","r1m2_CaravanGuardianSml301","r1m3_CaravanGuardianSml401","r2m1_CaravanGuardianSml401","r2m1_CaravanGuardianScout201","r2m2_CaravanGuardianScout301","Gladiator02"}

--Значения для лечения скриптовых проблем. Применяется в загрузке квестов для OnEvents квестов файла CONFIG.Default_Quests, "инвертируя" их. Например: Если при выдаче квеста он добавляет квестовый предмет через OnTake, то его надо удалить после этого.
--Пожалуйста, ВПИШИТЕ СЮДА СПОРНЫЕ КОМАНДЫ которые добавляет ваша модификация (без аргументов), иначе будут ошибки при загрузке квестов!
--НЕ РАБОТАЕТ С КОМАНДАМИ, У КОТОРЫХ НЕТ ДВИЖКОВОГО АНТОНИМА! Это будет баг, который не починить луашным яндередевом :(
CONFIG.Default_QuestOnEvents_CodeReverse = {
		["AddQuestItem"] = "g_Player:RemoveQuestItem",
		["AddHistory"] = "",
		["AddBook"] = "",
		["AddFadingMsgId"] = ""
	}

--Это сохранение загрузится, если не указан путь аргументом в команде загрузки, может быть nil. Пример: ["data\\profiles\\Player\\saves\\00000003"]
CONFIG.Default_SavePath = "data\\profiles\\Player\\saves\\00000080"

--Прочие значения "по умолчанию"
CONFIG.Default_SaveInfo = "saveinfo.xml"
CONFIG.Default_CurrentMap = "maps\\currentmap.xml"
CONFIG.Default_WeatherDetail = "weatherdetail.xml"
CONFIG.Default_Triggers = "triggers.xml"
CONFIG.Default_CinemaTriggers = "cinemaTriggers.xml"
CONFIG.Default_ExternalPaths = "external_paths.xml"
CONFIG.Default_Quests = "data\\gamedata\\quests.xml"

CONFIG.Default_ToleranceBackupScript = -1
CONFIG.Default_ToleranceRelationshipCoeff = 0.6		--> Определяет значение отношений, когда одно отношение переходит в другое. Например: отношение чуть меньше 1.6 и группировка уже становится вражеской
CONFIG.Default_ToleranceBackupFile = "data\\gamedata\\tolerance.bak"

CONFIG.Default_AttackTeamTactic = "MeatTeamTactic"  --> Имя тактики ai для тимы, когда они едут к кому-то. Другие тактики здесь: data/gamedata/gameobjects/tactics.xml

CONFIG.Default_ForbiddenTriggerEvents = {GE_TIME_PERIOD=1, GE_GAME_START=1, GE_FRAMES_PASSED=1}     --> По каким ивентам триггеры принудительно выключаются
CONFIG.Default_IgnoredTriggerEvents = {GE_FRAMES_PASSED=1}      --> По каким ивентам триггеры игнорируются для включения (для лечения дудос-багов)



-- //////////////////////////////////////////////////////////////////////////

-- ////////////////////////// LOAD USER SCRIPT //////////////////////////////

-- //////////////////////////////////////////////////////////////////////////


function GameSave:LoadUserScript()
	--поместите сюда свой скрипт, который нужно выполнить сразу после "загрузки" сохранения
	--используйте это место, как бы вы использовали server.lua или любой другой файл, либо триггер с GE_FRAMES_PASSED



	--глобальный хук из ExplorerMod, осторожнее!
	if DoSomeByLoadingMap then
		local s, e = pcall(function() return DoSomeByLoadingMap() end)
		if e then LOG("[E] Module GameSave.lua === ", e) end
	end
end

-- ///////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////



-- ///////////////////////////////////////////////////////////////////////////////

-- //////////////////////// LOCAL MODULE FUNCTIONS //////////////////////////////

-- ///////////////////////////////////////////////////////////////////////////////


local function string_strip(str)
	return str_gsub(str, "^%s*(.-)%s*$", "%1")
end

local function string_split(str, divider)
    local words = {}
    local word = ""
	local divider = divider or " "
    for i = 1, str_len(str) do
        local char = str_sub(str, i, i)
        if char == divider then
            if word ~= "" then
                t_insert(words, word)
                word = ""
            end
        else
            word = word .. char
        end
    end
    if word ~= "" then
        t_insert(words, word)
    end
    return words
end

local function table_contains_value(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

local function table_debug(tbl, indent)
    if type(tbl)~="table" then 
        return ""..tostring(tbl) 
    end
    indent = indent or 0
    local result = ""
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            result = result .. string.rep(" ", indent) .. key .. " = {\n" .. table_debug(value, indent + 4) .. string.rep(" ", indent) .. "}\n"
        else
            result = result .. string.rep(" ", indent) .. key .. " = \"" .. tostring(value) .. "\"\n"
        end
    end
    return result
end

--Improved3D
local function ParseCVector(CVector)
	CVector = tostring(CVector)
	if not str_find(CVector, "%(") then
		CVector = "("..CVector..")"
	end
	if not str_find(CVector, ",") then
		CVector = str_gsub(CVector, " ", ", ")
	end
	local userdata = dostring("local p = CVector"..CVector.."; return p")
	return userdata
end
local function ParseQuaternion(Quaternion)
	Quaternion = tostring(Quaternion)
	if not str_find(Quaternion, "%(") then
		Quaternion = "("..Quaternion..")"
	end
	if not str_find(Quaternion, ",") then
		Quaternion = str_gsub(Quaternion, " ", ", ")
	end
	local userdata = dostring("local r = Quaternion"..Quaternion.."; return r")
	return userdata
end




-- ///////////////////////////////////////////////////////////////////////////////

-- //////////////////////// GLOBAL MODULE FUNCTIONS //////////////////////////////

-- ///////////////////////////////////////////////////////////////////////////////


local GS = {}
GS.__index = GS

--#1
function GS:LoadGame(stringSaveDirPATH)
	GameSave.Path = stringSaveDirPATH or CONFIG.Default_SavePath
	if GameSave.Path then
		return GameSave:LoadGame()
	end
	LOG("[E] Module GameSave.lua === GameSave.Path is nil!")
end
--#2 save&load
--#3
function GS:LoadCached()
	local saveName, savePath = self:GetLoadedSaveName()
	self:UpdateLastSavePATH(savePath)
	return GameSave:GiveCachedDynamic()
end


--currentmap.xml
function GS:LoadToleranceStatus(stringCustomPathToCurrentMap)
	return CurrentMap:ToleranceManager(stringCustomPathToCurrentMap):Load()
end
--tolerance.bak
function GS:LoadToleranceStatusBackup()
	return CurrentMap:ToleranceManager():Load(nil, 1)
end
function GS:SaveToleranceStatusBackup()
	return CurrentMap:ToleranceManager():Load(nil, 0)
end


function GS:GetSaveFile(stringByLOGline)
	local SaveFileName = ""
	local strLastSaveFilePATH = XMLParser:QuickParseLine("exmachina.log", stringByLOGline) or ""
	if strLastSaveFilePATH~="" then
		strLastSaveFilePATH = str_sub(strLastSaveFilePATH, 1, -5)
	else
		LOG("[E] Module GameSave.lua === GS:GetSaveFile: Path error '"..strLastSaveFilePATH.."'")
		return nil
	end
	strLastSaveFilePATH = strLastSaveFilePATH..""..CONFIG.Default_SaveInfo
	if not str_find(strLastSaveFilePATH, "\\") then
		LOG("[E] Module GameSave.lua === GS:GetSaveFile: Path error '"..strLastSaveFilePATH.."'")
		return nil
	end
	local str = XMLParser:QuickGet(strLastSaveFilePATH, "Name").AsString or SaveFileName
	SaveFileName = string_strip(str)
	return SaveFileName, strLastSaveFilePATH
end

function GS:GetLoadedSaveName()
	local SaveFileName, strLastSaveFilePATH = self:GetSaveFile('Game loaded: "([^"]*)"')
	return SaveFileName, strLastSaveFilePATH
end
function GS:GetSavedFileName()
	local SaveFileName, strLastSaveFilePATH = self:GetSaveFile("Begin saving game '([^']*)'...")
	return SaveFileName, strLastSaveFilePATH
end

function GS:UpdateLastSavePATH(stringPATH)
	local stringPATH = str_gsub(stringPATH, CONFIG.Default_SaveInfo, CONFIG.Default_CurrentMap)
	if XMLParser:IsFileExists(stringPATH) then
		GameSave.LastSave_PATH = stringPATH
		self.LastSave_PATH = stringPATH
		LOG("[I] Module GameSave.lua === New save slot detected '"..stringPATH.."'")
	else
		GameSave.LastSave_PATH = GameSave.LastSave_PATH or nil
		self.LastSave_PATH = self.LastSave_PATH or nil
		LOG("[E] Module GameSave.lua === Save slot does not exist! '"..stringPATH.."'")
	end
end


--SavedPlayer
function GS:GetPlayerFrom(stringCustomPATHtoCurrentMap)
	local path = stringCustomPATHtoCurrentMap or self.LastSave_PATH
	if path then
		local PLAYER = XMLParser:ReadFromBigfile(path, "Object", "Prototype", "player", 1)
		PLAYER = PLAYER and PLAYER[1]
		self.Player = PLAYER
		return PLAYER
	end
end
function GS:GetFromSavedPlayer(xml_player, stringCustomPATHtoCurrentMap, stringItemTag, stringItemProperty, stringItemPropertyValue, stringPlayerProperty)
	local xml_player = xml_player or self:GetPlayerFrom(stringCustomPATHtoCurrentMap)
	if not stringPlayerProperty then
		local ItemsFromSavedPlayer = {}
		for i, child in ipairs( (xml_player and xml_player._itemChilds) or {} ) do
			if child._itemTag==stringItemTag then
				if stringItemProperty and child._itemProperties[stringItemProperty] then
					if stringItemPropertyValue and child._itemProperties[stringItemProperty]==stringItemPropertyValue then
						t_insert(ItemsFromSavedPlayer, child)
					elseif not stringItemPropertyValue then
						t_insert(ItemsFromSavedPlayer, child)
					end
				elseif not stringItemProperty then
					t_insert(ItemsFromSavedPlayer, child)
				end
			end
		end
		return next(ItemsFromSavedPlayer) and ItemsFromSavedPlayer
	elseif stringPlayerProperty then
		return xml_player and xml_player._itemProperties[stringPlayerProperty]
	end
end

function GS:GetPlayerAttr(xml_player, stringCustomPATHtoCurrentMap, stringFindAttr)
	--stringFindAttr = "Money" or "Belong" or ...
	local AttrValue = self:GetFromSavedPlayer(xml_player, stringCustomPATHtoCurrentMap, nil, nil, nil, stringFindAttr)
	return tonumber(AttrValue) or AttrValue
end
function GS:GetPlayerVehicle(xml_player, stringCustomPATHtoCurrentMap, stringVehicleName)
	local stringVehicleName = stringVehicleName or nil --or 'PlayerVehicle_[^"]*'
	local PlayerVehicle = self:GetFromSavedPlayer(xml_player, stringCustomPATHtoCurrentMap, "Object", "Name", stringVehicleName)
	PlayerVehicle = PlayerVehicle and PlayerVehicle[1]
	if PlayerVehicle and next(PlayerVehicle) then
		local DynScene = CurrentMap:DynamicSceneManager()

		function PlayerVehicle:GetRuntime()
			return DynScene:GetVehicleRuntime(self)
		end
		function PlayerVehicle:GetAllProperties()
			local Properties = {}
			local Attrs = self._itemProperties
			local Runtime = self:GetRuntime()
			for propertyName, propertyValue in pairs(Attrs or {}) do
				Properties[propertyName] = propertyValue
			end
			for propertyName, propertyValue in pairs((Runtime and Runtime._itemProperties) or {}) do
				Properties[propertyName] = propertyValue
			end
			return next(Properties) and Properties
		end
		function PlayerVehicle:GetProperty(stringPropertyName)
			local Attrs = self._itemProperties
			local Runtime = self:GetRuntime()
			local Property = Attrs and Attrs[stringPropertyName] or Runtime and Runtime[stringPropertyName]
			return tonumber(Property) or Property
		end
		function PlayerVehicle:GetRepository()
			return DynScene:GetVehicleRepository(self)
		end
		function PlayerVehicle:GetRepositoryAsPrototypes()
			local Inventory = {}
			local Repository = self:GetRepository()
			if Repository and next(Repository) then
				for i, item in ipairs(Repository) do
					if item._itemProperties.Prototype then
						t_insert(Inventory, item._itemProperties.Prototype)
					end
				end
			end
			return next(Inventory) and Inventory
		end
		function PlayerVehicle:GetRepositoryItemAmount(stringItemPrototype)
			local Inventory = self:GetRepositoryAsPrototypes()
			local Amount = 0
			local stringItemPrototype = stringItemPrototype or ""
			for i, prototype in ipairs(Inventory or {}) do
				if prototype==stringItemPrototype then
					Amount = Amount + 1
				end
			end
			return Amount
		end
		function PlayerVehicle:GetParts()
			return DynScene:GetVehicleParts(self)
		end
		function PlayerVehicle:GetPartByName(stringPartName)
			local Parts = self:GetParts()
			return DynScene:GetVehiclePartByName(self, Parts, stringPartName)
		end
		function PlayerVehicle:GetGadgets()
			local Gadgets = DynScene:GetVehicleGadgets(self)
			local gadgets = {}
			for i, gadget in ipairs(Gadgets or {}) do
				t_insert(gadgets, {
					SlotNum = gadget._itemProperties.SlotNum,
					Prototype = gadget._itemProperties.Prototype,
					ObjectId = gadget._itemProperties.ObjectId,
					Belong = gadget._itemProperties.Belong
				})
			end
			return next(gadgets) and gadgets
		end
		function PlayerVehicle:GetWheels()
			return DynScene:GetVehicleWheels(self)
		end

		return PlayerVehicle
	end
end


function GS:CreateAndSetObjectFrom(stringObjectName, cvectorNewPosition, stringCustomPATHtoCurrentMap)
	local path = stringCustomPATHtoCurrentMap or self.LastSave_PATH
	local stringObjectName = stringObjectName or ""
	local OBJECT
	if path then
		OBJECT = XMLParser:ReadFromBigfile(path, "Object", "Name", stringObjectName, 1)
		OBJECT = OBJECT and OBJECT[1]
		if OBJECT then
			local Property = OBJECT._itemProperties
			if cvectorNewPosition then
				if Property.Pos then Property.Pos = cvectorNewPosition
				elseif Property.Position then Property.Position = cvectorNewPosition end
			end
			local DynScene = CurrentMap:DynamicSceneManager(true)
			if DynScene:IsVehicle(OBJECT) then
				return DynScene:CreateAndSetVehicle(OBJECT)
			elseif DynScene:IsTeam(OBJECT) then
				return DynScene:CreateAndSetTeam(OBJECT)
			elseif DynScene:IsLocation(OBJECT) then
				return DynScene:CreateAndSetLocation(OBJECT)
			elseif DynScene:IsDynamic(OBJECT) then
				return DynScene:CreateAndSetBarricade(OBJECT)
			elseif DynScene:IsHuman(OBJECT) then
				return DynScene:CreateAndSetHuman(OBJECT)
			elseif DynScene:IsDot(OBJECT) then
				return DynScene:CreateAndSetDot(OBJECT)
			elseif DynScene:IsNPC(OBJECT) then
				return DynScene:SetNPCsSpokenCount(OBJECT)
			elseif DynScene:IsChest(OBJECT) then
				return DynScene:CreateAndSetChest(OBJECT)
			elseif DynScene:IsTown(OBJECT) then
				return DynScene:SetTownShops(OBJECT)
			else
				local obj = DynScene:CreateAndSetObject(Object)
				if not obj then
					LOG("[E] Module GameSave.lua === Unsorted object ERROR!", Property.Name)
				end
				return obj
			end
		end
	end
	LOG("[E] Module GameSave.lua === CreateAndSetObjectFrom(): loading ERROR! Path:", path, "OBJECT:\n"..table_debug(OBJECT))
end


-- ///////////////////////////////////////////////////////////////////////////////



function File:Clean(bCleanCachedDynamics)
    local before = gcinfo()

	if CurrentMap.DynamicSceneManager_data 	then CurrentMap.DynamicSceneManager_data.tree 	= nil end
	if CurrentMap.ToleranceManager_data 	then CurrentMap.ToleranceManager_data.tree 		= nil end
	if CurrentMap.QuestManager_data 		then CurrentMap.QuestManager_data.tree 			= nil end
    if CurrentMap.LevelInfoManager_data 	then CurrentMap.LevelInfoManager_data.tree 		= nil end
	if CurrentMap.HistoryWnd_data 			then CurrentMap.HistoryWnd_data.tree 			= nil end
	if CurrentMap.BooksWnd_data 			then CurrentMap.BooksWnd_data.tree 				= nil end
	if CurrentMap.Encyclopaedia_data 		then CurrentMap.Encyclopaedia_data.tree 		= nil end
	if CurrentMap.RadarWnd_data 			then CurrentMap.RadarWnd_data.tree 				= nil end

    -- local DSM_data = CurrentMap.DynamicSceneManager_data
    -- if DSM_data then
    --     DSM_data.Objects 		= nil
    --     DSM_data.PlayerInfo 		= nil
    --     DSM_data.Triggers 		= nil
    --     DSM_data.GlobalVars 		= nil
    --     DSM_data.InfectionZones 	= nil
    --     DSM_data.InfectionTeams 	= nil
    --     DSM_data.Locations 		= nil
    --     DSM_data.Towns 			= nil
    --     DSM_data.Teams 			= nil
    --     DSM_data.Vehicles 		= nil
    --     DSM_data.Dynamics 		= nil
    --     DSM_data.Humans 			= nil
    --     DSM_data.Dots 			= nil
    --     DSM_data.NPCs 			= nil
    --     DSM_data.Chests 			= nil
    --     DSM_data.WithNames 		= nil
    --     DSM_data.WithPrototypes 	= nil
    -- end

	if CurrentMap.DynamicSceneManager_data 	then CurrentMap.DynamicSceneManager_data 	= nil end
	if CurrentMap.ToleranceManager_data 	then CurrentMap.ToleranceManager_data 		= nil end
	if CurrentMap.QuestManager_data 		then CurrentMap.QuestManager_data 			= nil end
    if CurrentMap.LevelInfoManager_data 	then CurrentMap.LevelInfoManager_data 		= nil end
	if CurrentMap.HistoryWnd_data 			then CurrentMap.HistoryWnd_data 			= nil end
	if CurrentMap.BooksWnd_data 			then CurrentMap.BooksWnd_data 				= nil end
	if CurrentMap.Encyclopaedia_data 		then CurrentMap.Encyclopaedia_data 			= nil end
	if CurrentMap.RadarWnd_data 			then CurrentMap.RadarWnd_data 				= nil end

    CurrentMap.PATH 	= nil
    SaveInfo.PATH 		= nil
    WeatherDetail.PATH 	= nil
    Triggers.PATH 		= nil
    CinemaTriggers.PATH = nil
    ExternalPaths.PATH 	= nil
	Quests.PATH			= nil

    WeatherDetail.Data 	= nil
    Triggers.Data 		= nil
    CinemaTriggers.Data = nil
    ExternalPaths.Data 	= nil
	Quests.Data			= nil

	if bCleanCachedDynamics then
		GameSave.CachedDynamic_TownWorkshops = nil
		GameSave.CachedDynamic_TownShops 	 = nil
	end

    GameSave.LevelName 			= nil
    GameSave.SaveName 			= nil
    GameSave.KnownLevels 		= nil
    GameSave.WeatherState 		= nil
    GameSave.QuestItems 		= nil
    GameSave.RadarInfo 			= nil
    GameSave.JournalHistory 	= nil
    GameSave.JournalBooks 		= nil
    GameSave.JournalClans 		= nil
    GameSave.JournalPrototypes 	= nil
    GameSave.Vars 				= nil
    GameSave.Triggers 			= nil
	GameSave.InactiveTriggers	= nil
	GameSave.QuestMatrix		= nil
	GameSave.QuestIndex			= nil
    GameSave.InfectionZones 	= nil
    GameSave.InfectionTeams 	= nil
    GameSave.Locations 			= nil
    GameSave.Towns 				= nil
    GameSave.Teams 				= nil
    GameSave.Vehicles 			= nil
    GameSave.Dynamics 			= nil
    GameSave.Humans 			= nil
    GameSave.Dots 				= nil
    GameSave.NPCs 				= nil
    GameSave.Chests 			= nil
    GameSave.Player 			= nil
    GameSave.OtherNames 		= nil
    GameSave.OtherPrototypes 	= nil

    XMLParser:clearCache()

    collectgarbage()

    local after = gcinfo()

    LOG('[I] Module GameSave.lua === Cleanup:: ', before, after)
end

function File:Get()
	--сброс
	self:Clean()

	--переопределение конфига
	--[GLOBAL_...] --> глобальный хук из ExplorerMod, осторожнее!
	CONFIG.Default_GamePrototypes_Item = GLOBAL_ITEMLIST or CONFIG.Default_GamePrototypes_Item
	CONFIG.Default_GamePrototypes_Cabin = GLOBAL_VEHICLEPARTSLIST_CABINS or CONFIG.Default_GamePrototypes_Cabin
	CONFIG.Default_GamePrototypes_Cargo = GLOBAL_VEHICLEPARTSLIST_BASKETS or CONFIG.Default_GamePrototypes_Cargo
	CONFIG.Default_GamePrototypes_Vehicle = GLOBAL_NORMALVEHICLELIST or CONFIG.Default_GamePrototypes_Vehicle

	--базовые пути
	SaveInfo.PATH = GameSave.Path.."\\"..CONFIG.Default_SaveInfo
	CurrentMap.PATH = GameSave.Path.."\\"..CONFIG.Default_CurrentMap

	--базовая инфа сохранения
	SaveInfo.Name = string_strip(XMLParser:QuickGet(SaveInfo.PATH, "Name").AsString or "SAVENAME_IS_MISSING!")
	SaveInfo.LevelName = string_strip(XMLParser:QuickGet(SaveInfo.PATH, "LevelName").AsString or "LEVELNAME_IS_MISSING!")

	WeatherDetail.PATH = "data\\maps\\"..SaveInfo.LevelName.."\\"..CONFIG.Default_WeatherDetail
	Triggers.PATH = "data\\maps\\"..SaveInfo.LevelName.."\\"..CONFIG.Default_Triggers
	CinemaTriggers.PATH = "data\\maps\\"..SaveInfo.LevelName.."\\"..CONFIG.Default_CinemaTriggers
    ExternalPaths.PATH = "data\\maps\\"..SaveInfo.LevelName.."\\"..CONFIG.Default_ExternalPaths
	Quests.PATH = CONFIG.Default_Quests

	WeatherDetail.Data = XMLParser:ReadFromBigfile(WeatherDetail.PATH, "WeatherItem")
	Triggers.Data = XMLParser:ReadFromBigfile(Triggers.PATH, "trigger")
	CinemaTriggers.Data = XMLParser:ReadFromBigfile(CinemaTriggers.PATH, "trigger")
	Quests.Data = XMLParser:ReadFromBigfile(Quests.PATH, "quest")

	--открываем "стриминг" сейва
	if XMLParser:openQueue(CurrentMap.PATH) then
        XMLParser.data.ROOT = "GUI"
		return true
	end
	LOG("[E] Module GameSave.lua === CurrentMap.PATH IS_MISSING!")
end

function CurrentMap:LevelInfoManager()
	self.Encyclopaedia_data = nil
	self.BooksWnd_data = nil
	self.HistoryWnd_data = nil
	self.RadarWnd_data = nil
	self.DynamicSceneManager_data = nil
	self.ToleranceManager_data = nil
	self.QuestManager_data = nil
	self.LevelInfoManager_data = self.LevelInfoManager_data or {}
	local LevelInfoManager = self.LevelInfoManager_data
	function LevelInfoManager:init()
        if XMLParser:Tree({"LevelInfoManager"}):init() then
            return XMLParser:Tree()
        end
	end
	if not LevelInfoManager.tree then
		LevelInfoManager.tree = LevelInfoManager:init()
	end

	function LevelInfoManager:GetKnownLevels()
		local tree = self.tree
		if tree then
			local KnownLevels = tree:GetParam("KnownLevels").AsString or "huy"
			if KnownLevels~="huy" then
				KnownLevels = string_strip(KnownLevels)
				KnownLevels = string_split(KnownLevels)
				return KnownLevels
			end
		end
		LOG("[E] Module GameSave.lua === KnownLevels IS_MISSING!")
	end

	function LevelInfoManager:GetQuestItems()
		local tree = XMLParser:GetItemFromFile('<QuestItems', "QuestItems", "Object")
		if tree then
			local str = tree._itemProperties.PrototypeNames
			if str then
				str = string_strip(str)
				str = string_split(str)
				return str
			end
		end
		LOG("[E] Module GameSave.lua === QuestItems IS_MISSING!")
	end

	function LevelInfoManager:GetWeatherState()
		local tree = XMLParser:GetItemFromFile('<WeatherState', "WeatherState", "General")
		if tree then
			local weatherName = tree._itemProperties.WeatherName or ""
			local weatherTime = tree._itemProperties.DayTime or ""
			if     weatherTime=="0" then weatherTime = 6  --sunrise
			elseif weatherTime=="1" then weatherTime = 12 --day
			elseif weatherTime=="2" then weatherTime = 20 --sunset
			elseif weatherTime=="3" then weatherTime = 0  --night
			end
			local Time = tonumber(weatherTime) or 0
			local ID = 0
			local WeatherDetail = WeatherDetail.Data
			for i, weather in ipairs(WeatherDetail or {}) do
				local name = weather._itemProperties.name or "huy"
				if name==weatherName then
					ID = i
					break
				end
			end
			if ID>0 then
				return {id=ID, time=Time}
			end
		end
		LOG("[E] Module GameSave.lua === WeatherState IS_MISSING!")
	end
	
	return LevelInfoManager
end
function CurrentMap:DynamicSceneManager(bDoNotLoadScene)
	self.Encyclopaedia_data = nil
	self.BooksWnd_data = nil
	self.HistoryWnd_data = nil
	self.RadarWnd_data = nil
	self.LevelInfoManager_data = nil
	self.ToleranceManager_data = nil
	self.QuestManager_data = nil
	self.DynamicSceneManager_data = self.DynamicSceneManager_data or {}
	local DynamicSceneManager = self.DynamicSceneManager_data
	local s = self
	function DynamicSceneManager:init()
		if not bDoNotLoadScene then
			self.Objects = XMLParser:ReadFromBigfile(s.PATH, "Object")
		end
        self.PlayerInfo = nil
		self.Triggers = nil
		self.GlobalVars = nil
		self.InfectionZones = nil
        self.InfectionTeams = nil
		self.Locations = nil
		self.Towns = nil
		self.Teams = nil
		self.Vehicles = nil
		self.Dynamics = nil
		self.Humans = nil
		self.Dots = nil
		self.NPCs = nil
        self.Chests = nil
		self.WithNames = nil
		self.WithPrototypes = nil
		return true
	end
	if not DynamicSceneManager.tree then
		DynamicSceneManager.tree = DynamicSceneManager:init()
	end

	function DynamicSceneManager:IsTrigger(object)
		if object and object._itemProperties.Prototype=="trigger" then return true end
	end
	function DynamicSceneManager:IsVehicle(object)
		if object and object._itemProperties.Throttle then return true end
	end
	function DynamicSceneManager:IsHuman(object)
		if object and object._itemProperties.Prototype=="Human" then return true end
	end
	function DynamicSceneManager:IsTeam(object)
		if object and object._itemProperties.Prototype=="team" then return true end
	end
	function DynamicSceneManager:IsDynamic(object)
		if object and object._itemProperties.Probability then return true end
	end
	function DynamicSceneManager:IsTown(object)
		if object and object._itemProperties.PointOfViewInInterface then return true end
	end
	function DynamicSceneManager:IsLocation(object)
		if object and object._itemProperties.Prototype=="genericLocation" then return true end
	end
	function DynamicSceneManager:IsInfectionZone(object)
		if object and object._itemProperties.Prototype=="InfectionZone" then return true end
	end
	function DynamicSceneManager:IsDot(object)
		local childs = object and object._itemChilds[1]
		if childs then
			local childs_property = childs._itemProperties
			if childs_property then
				if childs_property.TimeForNextCheck then
					return true 
				end
			end
		end
	end
	function DynamicSceneManager:IsNPC(object)
		if object and object._itemProperties.Prototype=="NPC" then return true end
	end
    function DynamicSceneManager:IsChest(object)
		if object and object._itemProperties.Prototype=="someChest" then return true end
	end
    function DynamicSceneManager:IsPlayer(object)
		if object and object._itemProperties.Prototype=="player" then return true end
	end
	function DynamicSceneManager:IsGUN(object) 
		for i, child in ipairs(object._itemChilds or {}) do
			if child._itemTag=="Runtime" then
				if child._itemProperties.ModelName then
					return true
				end
			end
		end
	end
	function DynamicSceneManager:IsObjectWithName(object) 
		if object and object._itemProperties.Name then return true end
	end
	function DynamicSceneManager:IsObjectWithPrototype(object) 
		if object and object._itemProperties.Prototype then return true end
	end

    --///////////////////////

	function DynamicSceneManager:ProcessObjectScene(forWho, isCondition)
		local scene = self.Objects
		local forWho = forWho or {}
		local isCondition = type(isCondition)=="function" and isCondition or function() 
			LOG("[E] Module GameSave.lua === DynamicSceneManager:ProcessObjectScene :: arg isCondition IS_MISSING!")
			return false
		end
		if not forWho[1] then
			local i = 1
			while i <= t_getn(scene) do
				local cnd = isCondition(nil, scene[i])
				if cnd then
					t_insert(forWho, scene[i])
					scene[i] = scene[t_getn(scene)]
					scene[t_getn(scene)] = nil
				elseif cnd==false then
					break
				else
					i=i+1
				end
			end
		end
		return next(forWho) and forWho
	end
	
	function DynamicSceneManager:CallTriggers()
		local Triggers = self.Triggers or {}
		Triggers = self:ProcessObjectScene(Triggers, self.IsTrigger)
		if Triggers and Triggers[1] then
			self.Triggers = Triggers
			return Triggers
		end
		LOG("[E] Module GameSave.lua === Triggers IS_MISSING!")
	end
	function DynamicSceneManager:GetGlobalVars()
		local Triggers = self.Triggers or {}
		local Vars = self.GlobalVars or {}
		if not Vars or not Vars[1] then
			for i, trigger in ipairs(Triggers) do
				local name = trigger._itemProperties.Name 
				if name and name=="GlobalVar" then
					for i, var in ipairs(trigger._itemChilds or {}) do
						if var._itemTag=="Variable" then
							local var_value = var._itemProperties.GAIParam_Value
							local var_name = var._itemProperties.name
							if var_value and var_name then
								t_insert(Vars, {var_name, (tonumber(var_value) or var_value)})
							end
						end
					end
					break
				end
			end
		end
		if Vars[1] then
			self.GlobalVars = Vars
			return Vars
		end
		LOG("[E] Module GameSave.lua === Vars IS_MISSING!")
	end
	function DynamicSceneManager:GetTriggers()
		local Triggers = self.Triggers or {}
		if Triggers and Triggers[1] then
			local activeTriggers = {}
			local inactiveTriggers = {}
			for i, trigger in ipairs(Triggers) do
				if trigger._itemProperties.State~="TS_OFF" then
					t_insert(activeTriggers, trigger._itemProperties)
				else
					t_insert(inactiveTriggers, trigger._itemProperties)
				end
			end
			return (next(activeTriggers) and activeTriggers), (next(inactiveTriggers) and inactiveTriggers)
		end
		LOG("[E] Module GameSave.lua === Triggers IS_MISSING!")
	end
    function DynamicSceneManager:GetSiftedActiveTriggers()
		local ActiveTriggers, InactiveTriggers = self:GetTriggers()
		local Triggers = Triggers.Data or {}
		local CinemaTriggers = CinemaTriggers.Data or {}
        local activeSiftedTriggers = {}
		local inactiveSiftedTriggers = {}

        local function is_event(trigger, name)
            if trigger._itemProperties.Name==name then
                for i, event in ipairs(trigger._itemChilds or {}) do
                    if event._itemTag=="event" and not CONFIG.Default_IgnoredTriggerEvents[event._itemProperties.eventid] then
                        t_insert(activeSiftedTriggers, name)
                    end
                end
            end
        end
        for i, activeTrigger in ipairs(ActiveTriggers or {}) do
            local name = activeTrigger.Name
            for i, trigger in ipairs(Triggers) do
                is_event(trigger, name)
            end
			for i, trigger in ipairs(CinemaTriggers) do
                is_event(trigger, name)
            end
        end
		for i, inactiveTrigger in ipairs(InactiveTriggers or {}) do
            local name = inactiveTrigger.Name
            t_insert(inactiveSiftedTriggers, name)
        end

        return (next(activeSiftedTriggers) and activeSiftedTriggers), (next(inactiveSiftedTriggers) and inactiveSiftedTriggers)
    end

	function DynamicSceneManager:CallInfectionZones()
		local InfectionZones = self.InfectionZones or {}
		InfectionZones = self:ProcessObjectScene(InfectionZones, self.IsInfectionZone)
		if InfectionZones and InfectionZones[1] then
			self.InfectionZones = InfectionZones
			return InfectionZones
		end
		LOG("[E] Module GameSave.lua === InfectionZones IS_MISSING!")
	end
    function DynamicSceneManager:CallInfectionTeams(infectionZones)
        local InfectionTeams = self.InfectionTeams or {}
        local InfectionZones = infectionZones or self.InfectionZones or DynamicSceneManager:CallInfectionZones()
		for i, Infection in ipairs(InfectionZones or {}) do
            local InfectionName = Infection._itemProperties.Name or ""
            local InfectionPrototype = Infection._itemProperties.InfectionTeamPrototypeName or ""
            local _InfectionName = InfectionName.."_"..InfectionPrototype.."_GameLoad"
            local q = 1
			for i, Infection in ipairs(Infection._itemChilds or {}) do
                if Infection._itemTag=="Object" then
                    local Gang = Infection
                    Gang._InfectionPrototype = InfectionPrototype
                    Gang._InfectionName = InfectionName
                    Gang._Infection = _InfectionName.."_"..q
                    q=q+1
                    t_insert(InfectionTeams, Gang)
                end
			end
		end
        if InfectionTeams[1] then
            return InfectionTeams
        end
    end
	function DynamicSceneManager:CallLocations()
		local Locations = self.Locations or {}
		Locations = self:ProcessObjectScene(Locations, self.IsLocation)
		if Locations and Locations[1] then
			self.Locations = Locations
			return Locations
		end
		LOG("[E] Module GameSave.lua === Locations IS_MISSING!")
	end
	function DynamicSceneManager:CallTowns()
		local Towns = self.Towns or {}
		Towns = self:ProcessObjectScene(Towns, self.IsTown)
		if Towns and Towns[1] then
			self.Towns = Towns
			return Towns
		end
		LOG("[E] Module GameSave.lua === Towns IS_MISSING!")
	end
	function DynamicSceneManager:CallTeams()
		local Teams = self.Teams or {}
		Teams = self:ProcessObjectScene(Teams, self.IsTeam)
		if Teams and Teams[1] then
			self.Teams = Teams
			return Teams
		end
		LOG("[E] Module GameSave.lua === Teams IS_MISSING!")
	end
	function DynamicSceneManager:CallVehicles()
		local Vehicles = self.Vehicles or {}
		Vehicles = self:ProcessObjectScene(Vehicles, self.IsVehicle)
		if Vehicles and Vehicles[1] then
			self.Vehicles = Vehicles
			return Vehicles
		end
		LOG("[E] Module GameSave.lua === Vehicles IS_MISSING!")
	end
	function DynamicSceneManager:CallDynamics()
		local Dynamics = self.Dynamics or {}
		Dynamics = self:ProcessObjectScene(Dynamics, self.IsDynamic)
		if Dynamics and Dynamics[1] then
			self.Dynamics = Dynamics
			return Dynamics
		end
		LOG("[E] Module GameSave.lua === Dynamics IS_MISSING!")
	end
	function DynamicSceneManager:CallHumans()
		local Humans = self.Humans or {}
		Humans = self:ProcessObjectScene(Humans, self.IsHuman)
		if Humans and Humans[1] then
			self.Humans = Humans
			return Humans
		end
		LOG("[E] Module GameSave.lua === Humans IS_MISSING!")
	end
	function DynamicSceneManager:CallDots()
		local Dots = self.Dots or {}
		Dots = self:ProcessObjectScene(Dots, self.IsDot)
		if Dots and Dots[1] then
			self.Dots = Dots
			return Dots
		end
		LOG("[E] Module GameSave.lua === Dots IS_MISSING!")
	end
	function DynamicSceneManager:CallNPCs()
		--сначала CallLocations() и CallTowns() перед CallNPCs()
		local NPCs = self.NPCs or {}
		local Locations = self.Locations or {}
		local Towns = self.Towns or {}
		for _, Location in ipairs(Locations) do
			for _, child in ipairs(Location._itemChilds or {}) do
				if self:IsNPC(child) then
					t_insert(NPCs, child)
				end
			end
		end
		for _, Town in ipairs(Towns) do
			for _, Repository in ipairs(Town._itemChilds or {}) do
				for _, child in ipairs(Repository._itemChilds or {}) do
					if self:IsNPC(child) then
						t_insert(NPCs, child)
					end
				end
			end
		end
		if NPCs and NPCs[1] then
			self.NPCs = NPCs
			return NPCs
		end
		LOG("[E] Module GameSave.lua === NPCs IS_MISSING!")
	end
    function DynamicSceneManager:CallChests()
		local Chests = self.Chests or {}
		Chests = self:ProcessObjectScene(Chests, self.IsChest)
		if Chests and Chests[1] then
			self.Chests = Chests
			return Chests
		end
		LOG("[E] Module GameSave.lua === Chests IS_MISSING!")
	end
    function DynamicSceneManager:CallPlayer()
		local PlayerInfo = self.PlayerInfo or {}
		PlayerInfo = self:ProcessObjectScene(PlayerInfo, self.IsPlayer)
		if PlayerInfo and PlayerInfo[1] then
			self.PlayerInfo = PlayerInfo
			return PlayerInfo
		end
		LOG("[E] Module GameSave.lua === PlayerInfo IS_MISSING!")
	end

	function DynamicSceneManager:CallOtherObjectsWithNames()
		local WithNames = self.WithNames or {}
		WithNames = self:ProcessObjectScene(WithNames, self.IsObjectWithName)
		if WithNames and WithNames[1] then
			self.WithNames = WithNames
			return WithNames
		end
		LOG("[E] Module GameSave.lua === WithNames IS_MISSING!")
	end
	function DynamicSceneManager:CallOtherObjectsWithPrototypes()
		local WithPrototypes = self.WithPrototypes or {}
		WithPrototypes = self:ProcessObjectScene(WithNames, self.IsObjectWithPrototype)
		if WithPrototypes and WithPrototypes[1] then
			self.WithPrototypes = WithPrototypes
			return WithPrototypes
		end
		LOG("[E] Module GameSave.lua === WithPrototypes IS_MISSING!")
	end

    --///////////////////////

	function DynamicSceneManager:GetItemAffix(item)
		for _, child in ipairs(item._itemChilds or {}) do
			if child._itemTag=="Prefix" or child._itemTag=="Suffix" then
				return child._itemProperties.name
			end
		end
	end
	function DynamicSceneManager:GetItemRuntime(item)
		for i, child in ipairs(item._itemChilds or {}) do
			if child._itemTag=="Runtime" then
				return child
			end
		end
		return {}
	end

    function DynamicSceneManager:GetVehicleRuntime(vehicle)
		return self:GetItemRuntime(vehicle)
    end
    function DynamicSceneManager:GetVehicleParts(vehicle)
        for i, child in ipairs(vehicle._itemChilds or {}) do
            if child._itemTag=="Parts" then
                return child
            end
        end
    end
	function DynamicSceneManager:GetVehiclePartByName(vehicle, parts, stringPartName)
		local Parts = parts or self:GetVehicleParts(vehicle)
		local Part = {}
		local partName = stringPartName or "BASKET"
		for i, part in pairs((Parts and Parts._itemChilds) or {}) do
			if part._itemTag==partName then
				local Properties = part._itemProperties
				local PartInfo = part._itemChilds[1]._itemProperties
				local PartRuntime = part._itemChilds[1]._itemChilds[1]._itemProperties
				for propertyName, propertyValue in pairs(Properties or {}) do
					Part[propertyName] = propertyValue
				end
				for propertyName, propertyValue in pairs(PartInfo or {}) do
					Part[propertyName] = propertyValue
				end
				for propertyName, propertyValue in pairs(PartRuntime or {}) do
					Part[propertyName] = propertyValue
				end
				break
			end
		end
		return next(Part) and Part
	end
    function DynamicSceneManager:GetVehicleRepository(vehicle)
        for i, child in ipairs(vehicle._itemChilds or {}) do
            if child._itemTag=="Repository" then
                return child
            end
        end
    end
    function DynamicSceneManager:GetVehicleGadgets(vehicle)
        local gadgets = {}
        for i, child in ipairs(vehicle._itemChilds or {}) do
            if child._itemTag=="Object" then
                t_insert(gadgets, child)
            end
        end
        return next(gadgets) and gadgets
    end
	function DynamicSceneManager:GetVehicleWheels(vehicle)
		local Runtime = self:GetVehicleRuntime(vehicle)
		local wheels = {}
		for i, child in ipairs( (Runtime and Runtime._itemChilds) or {} ) do
			if child._itemTag=="Wheels" then
				for i, wheel in ipairs(child._itemChilds or {}) do
					if wheel._itemTag=="WheelInfo" then
						local Properties = wheel._itemProperties
						local ChildInfo = wheel._itemChilds[1]._itemProperties
						local ChildRuntime = wheel._itemChilds[1]._itemChilds[1]._itemProperties
						t_insert(wheels, {
							Id = Properties.Id,
							present = Properties.present,
							ObjectId = ChildInfo.ObjectId,
							Belong = ChildInfo.Belong,
							Prototype = ChildInfo.Prototype,
							Pos = ChildInfo.Pos,
							Rot = ChildInfo.Rot,
							CurAngle = ChildRuntime.CurAngle,
							Broken = ChildRuntime.Broken
						})
					end
				end
				break
			end
		end
		return next(wheels) and wheels
    end

    function DynamicSceneManager:GetTownShop(town)
        for i, child in ipairs(town._itemChilds or {}) do
            if child._itemTag=="Object" and child._itemProperties.Prototype=="shop" then
                return child
            end
        end
    end
    function DynamicSceneManager:GetTownWorkshop(town)
        for i, child in ipairs(town._itemChilds or {}) do
            if child._itemTag=="Object" and child._itemProperties.Prototype=="workshop" then
                return child
            end
        end
    end
	function DynamicSceneManager:GetShopItems(shop)
		local GunsAndGadgets = {}
		for _, child in ipairs(shop._itemChilds or {}) do
			if child._itemTag=="GunsAndGadgets" then
				GunsAndGadgets = child._itemChilds or {}
			end
		end
		return GunsAndGadgets
    end
    function DynamicSceneManager:GetWorkshopItems(workshop)
		local CabinsAndBaskets = {}
		local Vehicles = {}
		for _, child in ipairs(workshop._itemChilds or {}) do
			if child._itemTag=="CabinsAndBaskets" then
				for i, item in ipairs(child._itemChilds or {}) do
					CabinsAndBaskets[i] = {
						Prototype = item._itemProperties.Prototype,
						ObjectId = item._itemProperties.ObjectId,
						Price = item._itemProperties.Price
					}
					CabinsAndBaskets[i].Affix = self:GetItemAffix(item)
				end
			end
			if child._itemTag=="Vehicles" then
				Vehicles = child._itemChilds or {}
			end
		end
		return CabinsAndBaskets, Vehicles
    end
    function DynamicSceneManager:GetCurrentGeomRepositoryItemsAmount(geomRepository, itemName)
		local skoka = 0
		if geomRepository then
			while geomRepository:HasAmountOfItems(itemName, skoka+1) == 1 do
				skoka=skoka+1
			end
		end
		return skoka
    end
    function DynamicSceneManager:IsCurrentGeomRepositoryEmpty(geomRepository, tablePrototypes)
		for _, item in ipairs(tablePrototypes) do
			if self:GetCurrentGeomRepositoryItemsAmount(geomRepository, item)>0 then
				return false
			end
		end
		return true
	end
    function DynamicSceneManager:CleanCurrentWorkshop(stringWorkshopName, stringPrototypesName)
        local Workshop = GetEntityByName(stringWorkshopName)
        local RepositoryParts
        local RepositoryVehicles
        if Workshop then
            RepositoryParts = Workshop:GetRepositoryByTypename("CabinsAndBaskets")
            RepositoryVehicles = Workshop:GetRepositoryByTypename("Vehicles")
        end
        local PROTS = {
                Cabins = CONFIG.Default_GamePrototypes_Cabin,
                Baskets = CONFIG.Default_GamePrototypes_Cargo,
                Vehicles = CONFIG.Default_GamePrototypes_Vehicle
            }
        if stringPrototypesName then
            PROTS = {
                [stringPrototypesName] = PROTS[stringPrototypesName]
            }
        end
        for PrototypesFolder, Prototypes in pairs(PROTS) do
            local Repository = RepositoryParts
            if PrototypesFolder=="Vehicles" then
                Repository = RepositoryVehicles
            end
            if Repository then
				for _, item in ipairs(Prototypes) do
					local skoka = self:GetCurrentGeomRepositoryItemsAmount(Repository, item)
					Repository:RemoveItems(item, skoka)
					iscleanit = true
				end
            end
        end
		return iscleanit
	end
	function DynamicSceneManager:CleanCurrentShop(stringShopName)
        local Shop = GetEntityByName(stringShopName)
        local RepositoryItems
        if Shop then
            RepositoryItems = Shop:GetRepositoryByTypename("GunsAndGadgets")
        end
        local PROTS = {
                Items = CONFIG.Default_GamePrototypes_Item
            }
        for PrototypesFolder, Prototypes in pairs(PROTS) do
			local Repository = RepositoryItems
            if Repository then
				for _, item in ipairs(Prototypes) do
					local skoka = self:GetCurrentGeomRepositoryItemsAmount(Repository, item)
					Repository:RemoveItems(item, skoka)
					iscleanit = true
				end
            end
        end
		return iscleanit
	end
	function DynamicSceneManager:FillCurrentWorkshop(stringWorkshopName, tableWorkshop)
		local Workshop = GetEntityByName(stringWorkshopName)
        local RepositoryParts
        local RepositoryVehicles
        if Workshop then
            RepositoryParts = Workshop:GetRepositoryByTypename("CabinsAndBaskets")
            RepositoryVehicles = Workshop:GetRepositoryByTypename("Vehicles")
        end
		for i, child in ipairs(tableWorkshop._itemChilds or {}) do
			if child._itemTag=="CabinsAndBaskets" then
				for _, item in ipairs(child._itemChilds or {}) do
					RepositoryParts:AddItems(item._itemProperties.Prototype, 1)
				end
			elseif child._itemTag=="Vehicles" then
				for _, item in ipairs(child._itemChilds or {}) do
					RepositoryVehicles:AddItems(item._itemProperties.Prototype, 1)
				end
			end
		end
	end
	function DynamicSceneManager:FillCurrentShop(stringShopName, tableShop)
		local Shop = GetEntityByName(stringShopName)
        local RepositoryItems
        if Shop then
            RepositoryItems = Shop:GetRepositoryByTypename("GunsAndGadgets")
        end
		if RepositoryItems then
			for i, child in ipairs(tableShop._itemChilds or {}) do
				if child._itemTag=="GunsAndGadgets" then
					for _, item in ipairs(child._itemChilds or {}) do
						RepositoryItems:AddItems(item._itemProperties.Prototype, 1)
					end
				end
			end
		end
	end

    function DynamicSceneManager:ParseExternalPath(path, pathName)
        local result = {}
        t_insert(result, '\t<Path Name="'..pathName..'">')
        local start = 1
        while true do
            local sep_start, sep_end = str_find(path, ";", start)
            local chunk
            if sep_start then
                chunk = str_sub(path, start, sep_start - 1)
                start = sep_end + 1
            else
                chunk = str_sub(path, start)
            end
            local comma = str_find(chunk, ",")
            if comma then
                local x = str_sub(chunk, 1, comma - 1)
                local y = str_sub(chunk, comma + 1)
                t_insert(result, '\t\t<Point coord="'..x..' '..y..'" />')
            end
            if not sep_start then
                break
            end
        end
        t_insert(result, '\t</Path>')
        return result
    end
    function DynamicSceneManager:AddBlankExternalPaths(vehicles)
        ExternalPaths.Data = ExternalPaths.Data or {}
        local vehicles = vehicles or {}
        for i, vehicle in ipairs(vehicles) do
            local VehicleRuntime = self:GetVehicleRuntime(vehicle)
            local VehicleProperty = vehicle._itemProperties
            if VehicleRuntime then
                for i, child in ipairs(VehicleRuntime._itemChilds or {}) do
                    if child._itemTag=="Path" then
                        local PathPoints = child._itemProperties.PathPoints
                        local ExternalPathName = "GameLoadBlankExternalPath_"..tostring( VehicleProperty.Prototype ).."_"..tostring( VehicleProperty.ObjectId ).."_"..tostring(math.random(1e5))
                        local ExternalPathObject = self:ParseExternalPath(PathPoints, ExternalPathName)

                        vehicle._ExternalPath = ExternalPathName
                        t_insert(ExternalPaths.Data, {ExternalPathName, ExternalPathObject})
                    end
                end
            end
        end
        return vehicles
    end

    --///////////////////////

	function DynamicSceneManager:ApplyPartProperties(veh, PartName, PartInfo)
		local p = veh:GetPartByName(PartName)
		if PartName=="CHASSIS" then
			for modifier, value in pairs(PartInfo.PartProperty or {}) do
				if modifier=="Health" or modifier=="Fuel" then
					veh:AddModifier(str_gsub(modifier, "Health", "hp"), "= "..value)
				end
			end
			return
		end
		if PartInfo.PartAffix then
			p:ApplyAffixByName(PartInfo.PartAffix)
		end
		for property, value in pairs(PartInfo.PartRuntime or {}) do
			if property=="ShellsInPool" then
				p:SetShellsInPool(tonumber(value) or value)
			elseif property=="ShellsInCurrentCharge" then
				p:SetShellsInCurrentCharge(tonumber(value) or value)
			elseif not str_find(property, "Max") and not str_find(property, "MpHealth") and not str_find(property, "ModelName") and not str_find(property, "Prototype") then
				p:SetProperty(property, tonumber(value) or value)
			end
		end
		for property, value in pairs(PartInfo.PartProperty or {}) do
			if not str_find(property, "Max") and not str_find(property, "ObjectId") and not str_find(property, "ModelName") and not str_find(property, "Prototype") then
				p:SetProperty(property, tonumber(value) or value)
			end
		end
	end
	function DynamicSceneManager:ApplyGunProperties(gun, gunInfo)
		for property, value in pairs(gunInfo._itemProperties or {}) do
			if not str_find(property, "Prototype") and not str_find(property, "ObjectId") and not str_find(property, "Flags") then
				gun:SetProperty(property, tonumber(value) or value)
			end
		end
		local apply_gun_properties = function(properties)
			for property, value in pairs(properties or {}) do
				if property=="ShellsInPool" then
					gun:SetShellsInPool(tonumber(value) or value)
				elseif property=="ShellsInCurrentCharge" then
					gun:SetShellsInCurrentCharge(tonumber(value) or value)
				elseif not str_find(property, "MpHealth") and not str_find(property, "ModelName") and not str_find(property, "Prototype") then
					gun:SetProperty(property, tonumber(value) or value)
				end
			end
		end
		for i, child in ipairs(gunInfo._itemChilds or {}) do
			if child._itemTag=="Prefix" or child._itemTag=="Suffix" then
				local Affix = child._itemProperties.name
				gun:ApplyAffixByName(Affix)
			elseif child._itemTag=="Runtime" then
				apply_gun_properties(child._itemProperties or {})
			elseif child._itemTag=="Parts" then
				local Properties = {}
				for i, child in ipairs(child._itemChilds or {}) do
					local ppp = child._itemProperties or {}
					for property, value in pairs(ppp) do
						Properties[property] = value
					end
					for property, value in pairs( (ppp._itemChilds and ppp._itemChilds[1] and ppp._itemChilds[1]._itemProperties or {}) ) do
						Properties[property] = value
					end
				end
				apply_gun_properties(Properties)
			end
		end
	end

	--///////////////////////

	function DynamicSceneManager:CreateAndSetObject(object)
        local IsCreated = false
		local Property = object and object._itemProperties or {}
		if not getObj(Property.Name) then
			CreateNewObject{
				prototypeName = Property.Prototype, 
				objName = Property.Name, 
				belong = (tonumber(Property.Belong) or 1100)
			}
            IsCreated = true
		end
		local obj = getObj(Property.Name)
		if obj then
			local Pos = Property.Pos or Property.Position
			local Rot = Property.Rot or Property.Rotation
			local Bel = Property.Belong
			if Pos then
                obj:SetPosition( ParseCVector(Pos) )
            end
            if Rot then
                obj:SetRotation( ParseQuaternion(Rot) )
            end
			if Bel then
                obj:SetBelong( tonumber(Bel) or 1100 )
            end
		end
		return obj, IsCreated
	end
    function DynamicSceneManager:CreateAndSetVehicle(vehicle, object, isPlayer)
        local IsCreated = false
		local Property = object and object._itemProperties or {}
        if Property.Name then 
            vehicle = vehicle or getObj(Property.Name)
        elseif Property.ObjectId then 
            vehicle = vehicle or getObj( tonumber(Property.ObjectId) )
        end
		if not Property.Name then
			Property.Name = tostring("GameLoadVehicle_"..Property.Prototype.."_"..Property.ObjectId)
		end
		if not vehicle then
            CreateNewObject{
				prototypeName = Property.Prototype, 
				objName = Property.Name, 
				belong = (tonumber(Property.Belong) or 1100)
			}
            IsCreated = true
		else
			Property.Name = vehicle:GetName() or Property.Name or tostring("GameLoadVehicle_"..Property.Prototype.."_"..Property.ObjectId)
		end
		local veh = getObj(Property.Name) or getObj( tonumber(Property.ObjectId) )
		if veh and veh:GetClassName()=="Vehicle" then
            veh:setGodMode(1)

            local VehicleInfo = object._itemProperties
            local Pos = VehicleInfo.Pos
            local Rot = VehicleInfo.Rot
            if Pos then
                veh:SetPosition( ParseCVector(Pos) )
            end
            if Rot then
                veh:SetRotation( ParseQuaternion(Rot) )
            end

            local VehicleParts = self:GetVehicleParts(object)
            local VehicleRepository = self:GetVehicleRepository(object)
            local VehicleRuntime = self:GetVehicleRuntime(object)

            if VehicleParts then
                for i, Part in ipairs(VehicleParts._itemChilds or {}) do
                    local PartName = Part._itemTag
                    local PartProperty = Part._itemProperties
                    local PartRuntime = self:GetItemRuntime(Part)._itemProperties
                    local PartAffix = self:GetItemAffix(Part)

                    local PartInfo = {
                        PartName = PartName,
                        PartProperty = PartProperty,
                        PartRuntime = PartRuntime,
                        PartAffix = PartAffix
                    }
                    
                    if PartName=="CHASSIS" or PartName=="BASKET" or PartName=="CABIN" then
                        if PartName=="BASKET" or PartName=="CABIN" then
                            veh:SetNewPart(PartName, PartProperty.Prototype)
                        end
                        self:ApplyPartProperties(veh, PartName, PartInfo)
                    elseif veh:CanPartBeAttached(PartName) then
						veh:SetNewPart(PartName, PartProperty.Prototype)
						self:ApplyPartProperties(veh, PartName, PartInfo)
                    end
                end	
            end

            if VehicleRuntime then
                local Property = VehicleRuntime._itemProperties
                local ImmortalMode = Property.ImmortalMode
                local Throttle = Property.Throttle
                local Skin = Property.SkinNumber
                local LinearVelocity = Property.LinearVelocity
                local AngularVelocity = Property.AngularVelocity
                if ImmortalMode then
                    veh:setImmortalMode( tonumber(ImmortalMode) or 0)
                    ImmortalMode = nil
                end
                if Throttle then
                    veh:SetThrottle( tonumber(Throttle) or 0)
                    Throttle = nil
                end
                if Skin then
                    veh:SetSkin( tonumber(Skin) or 0)
                    Skin = nil
                end
                if LinearVelocity then
                    veh:SetLinearVelocity( ParseCVector(LinearVelocity) )
                    LinearVelocity = nil
                end
                if AngularVelocity then
                    veh:SetAngularVelocity( ParseCVector(AngularVelocity) )
                    AngularVelocity = nil
                end
                for property, value in pairs(Property) do
                    veh:SetProperty(property, tonumber(value) or value)
                end

                if CONFIG.DynamicScene_LoadVehicles_ExternalPaths then
                    if object._ExternalPath then
                        veh:SetExternalPathByName(object._ExternalPath)
                    end
                end
            end

            if VehicleRepository and not isPlayer then
                for i, item in ipairs(VehicleRepository._itemChilds or {}) do
                    local Prototype = item._itemProperties.Prototype
                    veh:AddItemsToRepository(Prototype, 1)
                end
            end

            veh:setGodMode(0)
		end
		return veh, IsCreated
	end
    function DynamicSceneManager:CreateAndSetTeam(team, object)
        local IsCreated = false
		local Property = object and object._itemProperties or {}
        Property.Name = Property.Name or object._Infection 
		if not team and not getObj(Property.Name) and not getObj( tonumber(Property.ObjectId) ) then
			CreateNewObject{
				prototypeName = "team", 
				objName = Property.Name, 
				belong = (tonumber(Property.Belong) or 1100)
			}
            IsCreated = true
		end
		local team = team or getObj(Property.Name) or getObj( tonumber(Property.ObjectId) )
		if team then
            local v = 0
            for i, child in ipairs(object._itemChilds or {}) do
                if child._itemTag=="Object" then
                    local vehicle = child
                    vehicle._itemProperties.Name = vehicle._itemProperties.Name or (Property.Name .. "_vehicle_"..v)
                    local Veh = self:CreateAndSetVehicle(nil, vehicle)
                    if Veh then
                        v=v+1
                        team:AddChild(Veh)
                    end
                elseif child._itemTag=="AI" then
                    local TeamAI = child
                    for i, StackElement in ipairs(TeamAI._itemChilds or {}) do
                        if StackElement._itemChilds[1] then
                            local GAIParam_Value = StackElement._itemChilds[1]._itemProperties.GAIParam_Value
                            local GAIParam_Type = StackElement._itemChilds[1]._itemProperties.GAIParam_Type
                            if GAIParam_Type=="AIPARAM_VECTOR" then
                                team:SetDestination( ParseCVector(GAIParam_Value) )
                            elseif GAIParam_Type=="AIPARAM_ID" then
                                team:SetProperty("TeamTacticPrototype", CONFIG.Default_AttackTeamTactic)
                            end
                        end
                    end
                end
            end
	        team:_AdjustBehaviour()
        end
        return team, IsCreated
    end

	function DynamicSceneManager:CreateAndSetLocation(Location)
		local Property = Location._itemProperties
		local loc = self:CreateAndSetObject(Location)
		if loc then
			if Property.Radius then loc:SetProperty("Radius", Property.Radius) end
			if Property.Active then loc:SetProperty("Active", Property.Active) end
		else
			LOG("[E] Module GameSave.lua === genericLocation object ERROR!", Property.Name)
		end
		return loc
	end
	function DynamicSceneManager:CreateAndSetBarricade(Barricade)
		local Property = Barricade._itemProperties
		local barricade = self:CreateAndSetObject(Barricade)
		if barricade then
			if Property.Probability then barricade:SetProperty("Probability", Property.Probability) end
		else
			LOG("[E] Module GameSave.lua === Dynamic object ERROR!", Property.Name)
		end
		return barricade
	end
	function DynamicSceneManager:CreateAndSetHuman(Human)
		local Property = Human._itemProperties
		local human = self:CreateAndSetObject(Human)
		if human then
			local PathsNames = Human._itemProperties.PathsNames or ""
			local CurPath = Human._itemChilds[1]._itemProperties.CurPathName
			for _, PathsName in ipairs( string_split(PathsNames) or {} ) do
				human:AddWalkPathByName(PathsName)
			end
			if CurPath and CurPath~="" then 
				human:SetWalkPathByName(CurPath) 
			end
		else
			LOG("[E] Module GameSave.lua === Human object ERROR!", Property.Name)
		end
		return human
	end
	function DynamicSceneManager:CreateAndSetDot(Dot)
		local Property = Dot._itemProperties
		local dot = self:CreateAndSetObject(Dot)
		if dot then
			local Health = Dot._itemChilds[1]._itemProperties.Health
			if Health then dot:AddModifier("hp", "= "..Health) end
		else
			LOG("[E] Module GameSave.lua === Dot object ERROR!", Property.Name)
		end
		return dot
	end
	function DynamicSceneManager:CreateAndSetChest(Chest)
		local Property = Chest._itemProperties
		local chest, created = self:CreateAndSetObject(Chest)
		if chest then
			if created then
				local Loot = Chest._itemChilds
				for i, loot in ipairs(Loot or {}) do
					if loot._itemTag=="Object" then
						local LootPrototype = loot._itemProperties.Prototype
						local LootBelong = loot._itemProperties.Belong
						local LootName = "GameLoadLootName_"..tostring( LootPrototype ).."_"..tostring( LootBelong  ).."_"..tostring(math.random(1e5))
						local lootID = CreateNewObject{prototypeName = LootPrototype, objName = LootName, belong = LootBelong}
						local item = GetEntityByID(lootID)
						if self:IsGUN(loot) then
							self:ApplyGunProperties(item, loot)
						else
							local Price = tonumber(loot._itemProperties and loot._itemProperties.Price)
							local Affix = tostring(DynScene:GetItemAffix(loot))
							if Price then
								item:SetProperty("Price", Price)
							end
							if Affix then
								item:ApplyAffixByName(Affix)
							end
						end
						chest:AddChild(item)
					end
				end
			end
		else
			LOG("[E] Module GameSave.lua === Chest object ERROR!", Property.Name)
		end
		return chest
	end
	function DynamicSceneManager:SetNPCsSpokenCount(NPC)
		local Property = NPC._itemProperties
		local npc = getObj(Property.Name)
		if npc then
			local SetSpokenCount = tonumber(Property.SpokenCount)
			npc:SetSpokenCount(SetSpokenCount or 0)
		else
			LOG("[E] Module GameSave.lua === NPC object ERROR!", Property.Name)
		end
		return npc
	end
	function DynamicSceneManager:SetTownShops(Town)
		local TownShop = self:GetTownShop(Town)
		local TownWorkshop = self:GetTownWorkshop(Town)
		local doit = false
		if TownShop then
			if not GameSave.CachedDynamic_TownShops then 
				GameSave.CachedDynamic_TownShops = {}
			end
			local ShopName = TownShop._itemProperties.Name or ""
			if self:CleanCurrentShop(ShopName) then
				self:FillCurrentShop(ShopName, TownShop)
				GameSave.CachedDynamic_TownShops[ShopName] = TownShop
				doit = true
				LOG("[I] Module GameSave.lua === CachedDynamic is ready:", ShopName, "Please, do save&load and then GS:LoadCached()")
			end
		end
		if TownWorkshop then
			if not GameSave.CachedDynamic_TownWorkshops then 
				GameSave.CachedDynamic_TownWorkshops = {}
			end
			local WorkshopName = TownWorkshop._itemProperties.Name or ""
			if self:CleanCurrentWorkshop(WorkshopName) then
				self:FillCurrentWorkshop(WorkshopName, TownWorkshop)
				GameSave.CachedDynamic_TownWorkshops[WorkshopName] = TownWorkshop
				doit = true
				LOG("[I] Module GameSave.lua === CachedDynamic is ready:", WorkshopName, "Please, do save&load and then GS:LoadCached()")
			end
		end
		return doit
	end

	return DynamicSceneManager
end
function CurrentMap:QuestManager()
	self.Encyclopaedia_data = nil
	self.BooksWnd_data = nil
	self.HistoryWnd_data = nil
	self.RadarWnd_data = nil
	self.DynamicSceneManager_data = nil
	self.LevelInfoManager_data = nil
	self.ToleranceManager_data = nil
	self.QuestManager_data = self.QuestManager_data or {}
	local QuestManager = self.QuestManager_data
	local s = self
	function QuestManager:init()
		self.Quests = XMLParser:ReadFromBigfile(s.PATH, "quest")
		self.QuestInfo = Quests.Data

		--LOG('self.QuestInfo\n'..table_debug(self.QuestInfo))

		self.QuestIndex = nil
		self.SaveQuestState = nil
		self.AllCalledQuests = nil
		self.CanBeGivenQuests = nil
		self.TakedQuests = nil
		self.FailedQuests = nil
		self.CompletedQuests = nil
		self.OtherQuests = nil
		return true
	end
	if not QuestManager.tree then
		QuestManager.tree = QuestManager:init()
	end

	function QuestManager:IsQuestCanBeGiven(quest) 
		if quest and quest._itemProperties.CanBeGiven=="1" then return true end
	end
	function QuestManager:IsQuestTaken(quest) 
		if quest and quest._itemProperties.IsTaken=="1" then return true end
	end
	function QuestManager:IsQuestCompleted(quest) 
		if quest and quest._itemProperties.CompleteStatus=="complete" then return true end
	end
	function QuestManager:IsQuestFailed(quest) 
		if quest and quest._itemProperties.CompleteStatus=="failed" then return true end
	end
	function QuestManager:IsOtherQuestStatus(quest) 
		if quest and quest._itemProperties.CompleteStatus=="not_complete" then return true end
	end
	function QuestManager:IsQuestWithName(quest, name) 
		if quest and quest._itemProperties.Name==name then return true end
	end
	function QuestManager:IsQuestAutomatic(quest)
		local Automatic = quest._itemProperties.Automatic
		return Automatic and Automatic=="1"
	end
	function QuestManager:IsQuestWithSubQuests(quest)
		if quest and quest._itemChilds[1] then return true end
	end

    --///////////////////////

	function QuestManager:ProcessQuest(forWho, isCondition, quests, name)
		local quests = quests or self.Quests
		local forWho = forWho or {}
		local isCondition = type(isCondition)=="function" and isCondition or function() 
			LOG("[E] Module GameSave.lua === QuestManager:ProcessQuest :: arg isCondition IS_MISSING!")
			return false
		end
		if not forWho[1] then
			local i = 1
			while i <= t_getn(quests) do
				local cnd = isCondition(nil, quests[i], name)
				if cnd then
					t_insert(forWho, quests[i])
					quests[i] = quests[t_getn(quests)]
					quests[t_getn(quests)] = nil
				elseif cnd==false then
					break
				else
					i=i+1
				end
			end
		end
		return next(forWho) and forWho
	end

	function QuestManager:CallQuestsCanBeGiven()
		local CanBeGiven = self.CanBeGivenQuests or {}
		CanBeGiven = self:ProcessQuest(CanBeGiven, self.IsQuestCanBeGiven)
		if CanBeGiven and CanBeGiven[1] then
			self.CanBeGivenQuests = CanBeGiven
			return CanBeGiven
		end
		LOG("[E] Module GameSave.lua === CanBeGivenQuests IS_MISSING!")
	end
	function QuestManager:CallQuestsTaken()
		local TakedQuests = self.TakedQuests or {}
		TakedQuests = self:ProcessQuest(TakedQuests, self.IsQuestTaken)
		if TakedQuests and TakedQuests[1] then
			self.TakedQuests = TakedQuests
			return TakedQuests
		end
		LOG("[E] Module GameSave.lua === TakedQuests IS_MISSING!")
	end
	function QuestManager:CallQuestsCompleted()
		local CompletedQuests = self.CompletedQuests or {}
		CompletedQuests = self:ProcessQuest(CompletedQuests, self.IsQuestCompleted)
		if CompletedQuests and CompletedQuests[1] then
			self.CompletedQuests = CompletedQuests
			return CompletedQuests
		end
		LOG("[E] Module GameSave.lua === CompletedQuests IS_MISSING!")
	end
	function QuestManager:CallQuestsFailed()
		local FailedQuests = self.FailedQuests or {}
		FailedQuests = self:ProcessQuest(FailedQuests, self.IsQuestFailed)
		if FailedQuests and FailedQuests[1] then
			self.FailedQuests = FailedQuests
			return FailedQuests
		end
		LOG("[E] Module GameSave.lua === FailedQuests IS_MISSING!")
	end
	function QuestManager:CallQuestsOther()
		local OtherQuests = self.OtherQuests or {}
		OtherQuests = self:ProcessQuest(OtherQuests, self.IsOtherQuestStatus)
		if OtherQuests and OtherQuests[1] then
			self.OtherQuests = OtherQuests
			return OtherQuests
		end
		LOG("[E] Module GameSave.lua === OtherQuests IS_MISSING!")
	end

	function QuestManager:CallAll()
		local Completed = self:CallQuestsCompleted()
		local Failed = self:CallQuestsFailed()
		local Taken = self:CallQuestsTaken()
		local CanBeGiven = self:CallQuestsCanBeGiven()
		local Other = {} --self:CallQuestsOther()

		self.AllCalledQuests = {Completed, Failed, Taken, CanBeGiven, Other}
		
		return Completed, Failed, Taken, CanBeGiven, Other
	end

	--///////////////////////

	function QuestManager:BuildQuestIndex() --local quest = self.QuestIndex["TRS_Quest4"]
		self.QuestIndex = {}
		local function ScanQuest(quest)
			local props = quest._itemProperties
			if props and props.Name then
				self.QuestIndex[props.Name] = quest
			end
			for _, child in ipairs(quest._itemChilds or {}) do
				ScanQuest(child)
			end
		end
		for _, quest in ipairs(self.QuestInfo or {}) do
			ScanQuest(quest)
		end
		GameSave.QuestIndex = self.QuestIndex
	end
	function QuestManager:BuildSaveIndex() --local state = self.SaveQuestState["TRS_Quest4"]
		self.SaveQuestState = {}
		local function Add(list, state)
			for _, quest in ipairs(list or {}) do
				local name = quest._itemProperties.Name
				self.SaveQuestState[name] = state
			end
		end
		Add(self.TakedQuests, "taken")
		Add(self.CompletedQuests, "completed")
		Add(self.FailedQuests, "failed")
	end

	function QuestManager:GetQuestOnEventsReversed(quest)
		local props = quest._itemProperties
		local reverse = CONFIG.Default_QuestOnEvents_CodeReverse or {}

		local function ReverseOnEvent(eventString)
			if eventString then
				eventString = str_gsub(eventString, "[%w_:.]", function(match) return reverse[match] or match end)
				eventString = str_gsub(eventString, "$s+%([^%)]*%)", "")
				return str_gsub(eventString, ";%s*;", ";")
			end
		end

		OnTake = ReverseOnEvent(props.OnTake)
		OnFail = ReverseOnEvent(props.OnFail)
		OnComplete = ReverseOnEvent(props.OnComplete)

		return OnTake~=props.OnTake and OnTake, OnFail~=props.OnFail and OnFail, OnComplete~=props.OnComplete and OnComplete
	end

	function QuestManager:GetQuestCommand(name)
		local cmd_take = 'if g_QuestStateManager:CanQuestBeGiven("'..name..'") and not g_QuestStateManager:IsQuestTaken("'..name..'") and not g_QuestStateManager:IsQuestComplete("'..name..'") and not g_QuestStateManager:IsQuestFailed("'..name..'") then g_QuestStateManager:TakeQuest("'..name..'") end'
		local cmd_complete = 'g_QuestStateManager:CompleteQuestIfTaken("'..name..'")'
		local cmd_fail = 'g_QuestStateManager:FailQuestIfTaken("'..name..'")'

		local state = self.SaveQuestState[name]
		local quest = self.QuestIndex[name]
		if not state then
			return nil
		end

		local automatic = self:IsQuestAutomatic(quest)
		local OnTake, OnFail, OnComplete = self:GetQuestOnEventsReversed(quest)

		cmd_take = OnTake and cmd_take.."; "..OnTake or cmd_take
		cmd_complete = OnComplete and cmd_complete.."; "..OnComplete or cmd_complete
		cmd_fail = OnFail and cmd_fail.."; "..OnFail or cmd_fail

		if state=="taken" and not automatic then
			return cmd_take
		elseif state=="completed" then
			if automatic then
				return cmd_complete
			else
				return {
					cmd_take,
					cmd_complete
				}
			end
		elseif state=="failed" then
			if automatic then
				return cmd_fail
			else
				return {
					cmd_take,
					cmd_fail
				}
			end
		end
		return nil
	end

	function QuestManager:BuildQuestPath(questName, path, visited)
		if visited[questName] then
			return
		end
		visited[questName] = true

		local quest = self.QuestIndex[questName]
		if not quest then
			return
		end

		local props = quest._itemProperties or {}
		if props.PrecedingQuests then
			local PrecedingQuests = string_split(props.PrecedingQuests)
			for _, precedingQuestName in ipairs(PrecedingQuests) do
				self:BuildQuestPath(precedingQuestName, path, visited)
			end
		end

		for _, subQuest in ipairs(quest._itemChilds or {}) do
			local subQuestName = subQuest._itemProperties.Name
			self:BuildQuestPath(subQuestName, path, visited)
		end

		local cmd = self:GetQuestCommand(questName)
		if type(cmd)=="table" then
			for _, line in ipairs(cmd) do
				t_insert(path, line)
			end
		elseif cmd then
			t_insert(path, cmd)
		end

		--LOG(questName, '\n'..table_debug(path))
	end
	function QuestManager:BuildQuestMatrixPaths()
		local matrix = {}
		local roots = {}

		self:BuildQuestIndex()
		self:BuildSaveIndex()

		for name in pairs(self.SaveQuestState) do
			t_insert(roots, name)
		end
		t_sort(roots)

		for _, questName in ipairs(roots) do
			local path = {}
			self:BuildQuestPath(questName, path, {})

			if t_getn(path)>0 then
				matrix[questName] = path
			end
		end

		return next(matrix) and matrix
	end

	function QuestManager:GetQuestMatrix()
		local Completed, Failed, Taken, CanBeGiven, Other = self:CallAll()
		--LOG('Completed\n'..table_debug(Completed), 'Failed\n'..table_debug(Failed), 'Taken\n'..table_debug(Taken), 'CanBeGiven\n'..table_debug(CanBeGiven), 'Other\n'..table_debug(Other))
		
		local QuestMatrixPaths = self:BuildQuestMatrixPaths()

		--LOG('QuestMatrixPaths\n'..table_debug(QuestMatrixPaths))
		--LOG('self.QuestInfo\n'..table_debug(self.QuestInfo))
		
		return QuestMatrixPaths
	end

	return QuestManager
end
function CurrentMap:ToleranceManager(stringCustomPathToSaveFile)
	self.Encyclopaedia_data = nil
	self.BooksWnd_data = nil
	self.HistoryWnd_data = nil
	self.RadarWnd_data = nil
	self.DynamicSceneManager_data = nil
	self.LevelInfoManager_data = nil
	self.QuestManager_data = nil
	self.ToleranceManager_data = self.ToleranceManager_data or {}
	local ToleranceManager = self.ToleranceManager_data
	local success, file
	function ToleranceManager:init(stringCustomPathToSaveFile)
		if stringCustomPathToSaveFile then
			local root_tag = ""
			self.SaveFilePATH = stringCustomPathToSaveFile or "data\\gamedata\\relationship.xml" --or "data\\profiles\\Player\\saves\\00000000\\maps\\currentmap.xml"
			if str_find(self.SaveFilePATH, "relationship.xml") then
				root_tag = "relationship"
			elseif str_find(self.SaveFilePATH, "currentmap.xml") then
				root_tag = "DynamicScene"
			end
			success, file = XMLParser:init(self.SaveFilePATH, root_tag, nil, false)
			if success then
				if XMLParser:Tree({"relationship"}):init() then
					return XMLParser:Tree()
				end
			end
        elseif XMLParser:Tree({"relationship"}):init() then
            return XMLParser:Tree()
        end
	end
	if not ToleranceManager.tree then
		ToleranceManager.tree = ToleranceManager:init(stringCustomPathToSaveFile)
	end

	local function parse_numbers(str)
		local numbers = {}
		local i = 1
		while i <= str_len(str) do
			if str_sub(str, i, i) ~= " " then
				local num_str = ""
				while i <= str_len(str) and str_find(str_sub(str, i, i), "%d") do
					num_str = num_str .. str_sub(str, i, i)
					i = i + 1
				end
				if num_str ~= "" then
					t_insert(numbers, tonumber(num_str))
				end
			else
				i = i + 1
			end
		end
		return numbers
	end
	local function create_backup(skoka, tolerance_backup_path) --skoka белонгов
		local calcStatus = 0
		local backup_file = io_open(tolerance_backup_path, "w")
		if backup_file then
			--гетаем
			ToleranceManager.BackupToleranceStatus = {}
			local BackupToleranceStatus = ToleranceManager.BackupToleranceStatus
			local raz,dva = skoka,skoka
			for i=1, raz do
				BackupToleranceStatus[i] = {}
				for j=1, dva do
					BackupToleranceStatus[i][j] = GetTolerance(i+1000, j+1000)
				end
			end
			--пишем
			local w,f=1,1
			while BackupToleranceStatus[w] do
				f=1
				while BackupToleranceStatus[w][f] do
					backup_file:write(w.." "..f.." "..BackupToleranceStatus[w][f].."\n")
					calcStatus = 1
					f=f+1
				end
				w=w+1
			end
			backup_file:close()
			LOG("[I] Module GameSave.lua === ToleranceManager: Create backup relationship in \""..tostring(tolerance_backup_path).."\"")
		end
		if file then 
			file:close() 
			file = nil
		end
		if calcStatus == 0 then
			LOG("[E] Module GameSave.lua === Relationship BackupFile reading error!!!")
			return nil
		end
		return calcStatus
	end
	local function read_backup(tolerance_backup_path)
		local calcStatus = 0
		local backup_file = io_open(tolerance_backup_path, "r")
		if backup_file then
			for line in backup_file:lines() do
				local set = parse_numbers(line)
				local who = set[1]
				local forwhom = set[2]
				local tolerance = set[3]
				if who and forwhom and tolerance then
					SetTolerance(who+1000, forwhom+1000, tolerance)
					calcStatus = 1
				else
					calcStatus = 0
					break
				end
			end
			LOG("[I] Module GameSave.lua === ToleranceManager: Read & apply relationship from \""..tostring(tolerance_backup_path).."\"")
		end
		if file then 
			file:close() 
			file = nil
		end
		if calcStatus == 0 then
			LOG("[E] Module GameSave.lua === Relationship BackupFile reading error!!!")
			return nil
		end
		return calcStatus
	end


	function ToleranceManager:CalcRelationship(MinPlayerID, MaxPlayerID, DefaultTolerance, RelationshipItems, RelationshipChilds, BackupScript, relationship_coeff, tolerance_backup_path)
		LOG("[I] Module GameSave.lua === ToleranceManager: Calc relationship...")
		local calcStatus = 0
		local function get_status(Tolerance)
				local Status = self.RS_ENEMY
				if Tolerance=="ally" then Status = self.RS_ALLY end
				if Tolerance=="neutral" then Status = self.RS_NEUTRAL end
				if Tolerance=="own" then Status = self.RS_OWN end
				return Status
			end

		--воздаем дефолт
		local MinPlayerID = MinPlayerID or 1000
		local MaxPlayerID = MaxPlayerID or 1200
		local DefaultTolerance = DefaultTolerance or "enemy"
		local Items = RelationshipItems or {}
		local Childs = RelationshipChilds
		local skoka = MaxPlayerID - MinPlayerID
		if BackupScript==0 then
			return create_backup(skoka, tolerance_backup_path)
		elseif BackupScript==1 then
			return read_backup(tolerance_backup_path)
		end
		local Status = get_status(DefaultTolerance)
		local raz,dva = skoka,skoka
		for i=1, raz do
			for j=1, dva do
				SetTolerance(i+1000, j+1000, Status)
				calcStatus = 1
			end
		end

		--воздаем чо должно быть
		if not Childs then
			for i, set in ipairs(Items) do
				local item_property = set._itemProperties
				local tolerance = tostring(item_property.tolerance)
				local forwhom = tostring(item_property.forwhom)
				local who = tostring(item_property.who)
				if tolerance~="nil" and forwhom~="nil" and who~="nil" then
					local belongs_forwhom = parse_numbers(forwhom)
					local belongs_who = parse_numbers(who)
					Status = get_status(tolerance)
					for i, forwhom in ipairs(belongs_forwhom) do
						for i, who in ipairs(belongs_who) do
							--LOG(forwhom, who, Status)
							SetTolerance(forwhom, who, Status)
							calcStatus = 2
						end
					end
				end
			end
			--тут уязвимость! \/
						--я уязвимость :3
			--тут уязвимость! /\
		else
			for i, set in ipairs(Items) do
				local who = set._itemProperties.id
				local b = 1
				while Childs[i]._itemChilds[b] ~= nil do
					local child = Childs[i]._itemChilds[b]._itemProperties
					local forwhom = child.id
					local tolerance = child.tolerance
					if (who and who~="nil") and (forwhom and forwhom~="nil") and (tolerance and tolerance~="nil") then
						Status = self.RS_ENEMY
						tolerance = tonumber(tolerance)
						who = tonumber(who)
						forwhom = tonumber(forwhom)
						if tolerance>3+relationship_coeff then 
							Status = self.RS_OWN
						elseif tolerance>2+relationship_coeff then 
							Status = self.RS_ALLY
						elseif tolerance>1+relationship_coeff then 
							Status = self.RS_NEUTRAL 
						end
						--LOG(forwhom, who, Status)
						SetTolerance(forwhom, who, Status)
						calcStatus = 2
					end
					b=b+1
				end
			end
		end
		if file then
			file:close()
			file = nil
		end
		if 2>calcStatus then
			LOG("[E] Module GameSave.lua === Relationship reading error!!!")
			return nil
		end
		LOG("[I] Module GameSave.lua === ToleranceManager: Apply new relationship from \""..tostring(self.SaveFilePATH).."\"")
		return calcStatus
	end

	function ToleranceManager:Load(stringToleranceBackupFilePATH, intBackupScript, floatRelationshipCoeff)
		if not self.tree and not intBackupScript then
			LOG("[E] Module GameSave.lua === Relationship reading error!!!")
			return nil
		end
		self.RS_ENEMY = RS_ENEMY or 1
		self.RS_NEUTRAL = RS_NEUTRAL or 2
		self.RS_ALLY = RS_ALLY or 3
		self.RS_OWN = RS_OWN or 4

		self.BackupScript = intBackupScript or CONFIG.Default_ToleranceBackupScript
		self.RelationshipCoeff = floatRelationshipCoeff or CONFIG.Default_ToleranceRelationshipCoeff
		self.ToleranceBackupFile = stringToleranceBackupFilePATH or CONFIG.Default_ToleranceBackupFile
		
		local BackupScript = self.BackupScript
		local relationship_coeff = self.RelationshipCoeff	
		local tolerance_backup_path = self.ToleranceBackupFile		

		local MinPlayerID
		local MaxPlayerID
		local DefaultTolerance
		local sets_who
		local sets_forwhom

		if self.tree then
			MinPlayerID = self.tree:GetParam("MinPlayerID").AsInt
			MaxPlayerID = self.tree:GetParam("MaxPlayerID").AsInt
			DefaultTolerance = self.tree:GetParam("DefaultTolerance").AsString
			sets_who = self.tree:GetItems()
			sets_forwhom = self.tree:GetChilds()
		end

		return self:CalcRelationship(MinPlayerID, MaxPlayerID, DefaultTolerance, sets_who, sets_forwhom,	BackupScript, relationship_coeff, tolerance_backup_path)
	end

	return ToleranceManager
end
function CurrentMap:Encyclopaedia()
	self.LevelInfoManager_data = nil
	self.HistoryWnd_data = nil
	self.BooksWnd_data = nil
	self.RadarWnd_data = nil
	self.DynamicSceneManager_data = nil
	self.ToleranceManager_data = nil
	self.QuestManager_data = nil
	self.Encyclopaedia_data = self.Encyclopaedia_data or {}
	local Encyclopaedia = self.Encyclopaedia_data
	function Encyclopaedia:init()
		if XMLParser:Tree({"Encyclopaedia"}):init() then
			return XMLParser:Tree()
		end
	end
	if not Encyclopaedia.tree then
		Encyclopaedia.tree = Encyclopaedia:init()
	end

	function Encyclopaedia:GetClans()
		local tree = self.tree
		if tree then
			local Clans = {}
			local clans = tree:GetObj({"Clans"})
			if clans then
				local belongs = clans:GetProperty("Belongs").AsString
				belongs = string_split(belongs)
				Clans = belongs
			end
			if Clans[1] then
				return Clans
			end
		end
		LOG("[E] Module GameSave.lua === EncyclopaediaClans IS_MISSING!")
	end

	function Encyclopaedia:GetPrototypes()
		local tree = self.tree
		if tree then
			local Prototypes = {}
			if tree:CaptureInnerTree({"Prototypes"}) then
				local prots = tree:GetItems()
				if prots then
					local retVal = ""
					for i, prts in ipairs(prots or {}) do
						local str = prts._itemProperties.PrototypeNames
						str = string_strip(str)
						retVal = retVal .. str .. " "
					end
					local protatoes = string_split(retVal)
					Prototypes = protatoes
				end
			end
			if Prototypes[1] then
				return Prototypes
			end
		end
		LOG("[E] Module GameSave.lua === EncyclopaediaPrototypes IS_MISSING!")
	end
	
	return Encyclopaedia
end
function CurrentMap:HistoryWnd()
	self.Encyclopaedia_data = nil
	self.BooksWnd_data = nil
	self.LevelInfoManager_data = nil
	self.RadarWnd_data = nil
	self.DynamicSceneManager_data = nil
	self.ToleranceManager_data = nil
	self.QuestManager_data = nil
	self.HistoryWnd_data = self.HistoryWnd_data or {}
	local HistoryWnd = self.HistoryWnd_data
	function HistoryWnd:init()
		if XMLParser:Tree({"Records"}):init() then
			return XMLParser:Tree()
		end
	end
	if not HistoryWnd.tree then
		HistoryWnd.tree = HistoryWnd:init()
	end

	function HistoryWnd:GetHistories()
		local tree = self.tree
		if tree then
			local Histories = {}
			local histories = tree:GetItems()
			local time = tree:GetChilds()
			for i, history in ipairs(histories or {}) do
				local name = history._itemProperties.TextId
				local time = time[i]._itemChilds[1]._itemProperties.GAIParam_Value
				t_insert(Histories, {name, time})
			end
			if Histories[1] then
				return Histories
			end
		end
		LOG("[E] Module GameSave.lua === HistoryWnd IS_MISSING!")
	end
	
	return HistoryWnd
end
function CurrentMap:BooksWnd()
	self.Encyclopaedia_data = nil
	self.LevelInfoManager_data = nil
	self.HistoryWnd_data = nil
	self.RadarWnd_data = nil
	self.DynamicSceneManager_data = nil
	self.ToleranceManager_data = nil
	self.QuestManager_data = nil
	self.BooksWnd_data = self.BooksWnd_data or {}
	local BooksWnd = self.BooksWnd_data
	function BooksWnd:init()
		if XMLParser:Tree({"BooksWnd"}):init() then
			return XMLParser:Tree()
		end
	end
	if not BooksWnd.tree then
		BooksWnd.tree = BooksWnd:init()
	end

	function BooksWnd:GetBooks()
		local tree = self.tree
		if tree then
			local Books = {}
			local books = tree:GetChilds()
			for i, book in ipairs(books or {}) do
				local name = book._itemChilds[1]._itemProperties.NameId
				t_insert(Books, name)
			end
			if Books[1] then
				return Books
			end
		end
		LOG("[E] Module GameSave.lua === BooksWnd IS_MISSING!")
	end
	
	return BooksWnd
end
function CurrentMap:RadarWnd()
	self.Encyclopaedia_data = nil
	self.LevelInfoManager_data = nil
	self.HistoryWnd_data = nil
	self.BooksWnd_data = nil
	self.DynamicSceneManager_data = nil
	self.ToleranceManager_data = nil
	self.QuestManager_data = nil
	self.RadarWnd_data = self.RadarWnd_data or {}
	local RadarWnd = self.RadarWnd_data
	function RadarWnd:init()
		return XMLParser:GetItemFromFile('<Radar', "Radar", "GUI")
	end
	if not RadarWnd.tree then
		RadarWnd.tree = RadarWnd:init()
	end

	function RadarWnd:GetRadar()
		local radar = self.tree
		if radar then
			local ScanRadius = (tonumber(radar._itemProperties.ScanRadius or "") or 200)
			local NavPointsAllowed = (tostring(radar._itemProperties.NavPointsAllowed)=="1" and true or false)
			local VehiclesAllowed = (tostring(radar._itemProperties.VehiclesAllowed)=="1" and true or false)
			local TurretsAllowed = (tostring(radar._itemProperties.TurretsAllowed)=="1" and true or false)
			local DistancesAllowed = (tostring(radar._itemProperties.DistancesAllowed)=="1" and true or false)
			return {
				ScanRadius = ScanRadius, 
				NavPointsAllowed = NavPointsAllowed, 
				VehiclesAllowed = VehiclesAllowed,
				TurretsAllowed = TurretsAllowed,
				DistancesAllowed = DistancesAllowed
			}
		end
		LOG("[E] Module GameSave.lua === RadarWnd IS_MISSING!")
	end
	
	return RadarWnd
end


function GameSave:SetLevelTriggersDeactivate()
    local deactiveTriggers = {}
    local ForbiddenEvents = CONFIG.Default_ForbiddenTriggerEvents
    local triggers_paths = {CinemaTriggers.PATH, Triggers.PATH}
    for file, path in ipairs(triggers_paths) do
        local s,f = XMLParser:init(path, "triggers", nil, false)
        if s then
            if XMLParser:Tree({"triggers"}):init() then
                local trigs = XMLParser:Tree():GetItems()
                for i, trig in ipairs(trigs) do
                    local trName = trig._itemProperties.Name or ""
                    if trig._itemProperties.active=="1" then
                        local trigger = XMLParser:GetItemFromFile('Name%s*=%s*"'..trName..'"', "trigger", "triggers")
                        if trigger then
                            for i, tr_child in ipairs(trigger._itemChilds) do
                                if ForbiddenEvents[tr_child._itemProperties.eventid or ""] then
                                    --LOG("off", path, trName)
                                    XMLParser:SetItemValueInFile('Name%s*=%s*"'..trName..'"', "trigger", "triggers", "active", nil, "0")
                                    t_insert(deactiveTriggers, trName)
                                end
                            end
                        end
                    end
                end
            end
            XMLParser:save()
        end
    end
    self.DeactivatedLevelTriggers = deactiveTriggers
    self.LevelTriggersPaths = triggers_paths
    return deactiveTriggers
end
function GameSave:SetLevelTriggersActivate()
    local activeTriggers = self.DeactivatedLevelTriggers
    local triggers_paths = self.LevelTriggersPaths
    for file, path in ipairs(triggers_paths) do
        XMLParser:openQueue(path)
        for i, triggerName in ipairs(activeTriggers) do
            --LOG("on", path, triggerName)
            XMLParser:SetItemValueInFile('Name%s*=%s*"'..triggerName..'"', "trigger", "triggers", "active", nil, "1")
        end
        XMLParser:closeQueue()
    end
    return activeTriggers
end
function GameSave:SetLevelCoroutineTrigger()
    local CTname = "trLoadGameCoroutineTrigger"
    XMLParser:openQueue("data\\maps\\"..self.LevelName.."\\"..CONFIG.Default_Triggers)
    XMLParser:RemoveItemFromFile('Name%s*=%s*"'..CTname..'"', "trigger", "triggers")
    XMLParser:trigger(CTname):Add(1, {
        '<event eventid="GE_FRAMES_PASSED" />'
    }, {
        'GameSaveFakeCoroutineScript()',
        'trigger:Deactivate()'
    })
    XMLParser:closeQueue()
end
function GameSave:RemoveLevelCoroutineTrigger()
    local CTname = "trLoadGameCoroutineTrigger"
    XMLParser:openQueue("data\\maps\\"..self.LevelName.."\\"..CONFIG.Default_Triggers)
    XMLParser:RemoveItemFromFile('Name%s*=%s*"'..CTname..'"', "trigger", "triggers")
    XMLParser:closeQueue()
end
function GameSave:SetLevelBlankExternalPaths()
    local s = self
    local DynScene = CurrentMap:DynamicSceneManager()

    local AddBlankExternalPaths_ToTeams = function(teams)
            for i, team in ipairs(teams) do
                local Vehicles = {}
                for i, child in ipairs(team._itemChilds or {}) do
                    if child._itemTag=="Object" then
                        t_insert(Vehicles, child)
                    end
                end
                DynScene:AddBlankExternalPaths(Vehicles)
            end
            return teams
        end

    if s.Vehicles then
        s.Vehicles = DynScene:AddBlankExternalPaths(s.Vehicles)
    end
    if s.Teams then
        s.Teams = AddBlankExternalPaths_ToTeams(s.Teams)
    end
    if s.InfectionTeams then
        s.InfectionTeams = AddBlankExternalPaths_ToTeams(s.InfectionTeams)
    end

    local Player = (s.Player and s.Player[1] or {})
    local PlayerVehicle
    for i, child in ipairs(Player._itemChilds or {}) do
        if child._itemTag=="Object" then
            PlayerVehicle = child
            break
        end
    end
    if PlayerVehicle then
        DynScene:AddBlankExternalPaths({PlayerVehicle})
    end

    if ExternalPaths.Data and ExternalPaths.Data[1] then
        --быстрая затычка без XMLParser, а то чето дорогие манипуляции
        local f = io_open(ExternalPaths.PATH, "r")
        if f then
            local content = f:read("*a")
            f:close()
            local insert = ""
            for i, path in ipairs(ExternalPaths.Data) do
                insert = insert.."\n"..t_concat(path[2], "\n")
            end
            content = string.gsub(content, "</Paths>", insert.."\n</Paths>")

            local f = io_open(ExternalPaths.PATH, "w")
            f:write(content)
            f:close()
        end
    end
end
function GameSave:RemoveLevelBlankExternalPaths()
    if ExternalPaths.Data and ExternalPaths.Data[1] then
        --быстрая затычка без XMLParser, а то чето дорогие манипуляции
        local f = io_open(ExternalPaths.PATH, "r")
        if f then
            local content = f:read("*a")
            f:close()

            local removePathByName = function(content, name)
                    local pattern = "\n?%s*<Path%s+Name%s*=%s*\""..name.."\".-</Path>"
                    content = string.gsub(content, pattern, "")

                    return content
                end

            for i, path in ipairs(ExternalPaths.Data) do
                local name = path[1]
                content = removePathByName(content, name)
            end

            local f = io_open(ExternalPaths.PATH, "w")
            f:write(content)
            f:close()
        end
    end
end

function GameSave:CreateChest(position)
    local YASHIK = GetEntityByName("GameLoadChest")
    local chest
    if YASHIK then
        chest = GetEntityByID(YASHIK:GetId())
    else
        local chestID = CreateNewObject{prototypeName = "someChest", objName = "GameLoadChest"}	
        chest = GetEntityByID(chestID)
    end
    chest:SetPosition(position)
    return chest
end
function GameSave:AddPlayerGadgetsToChest(gadgets, position)
    if gadgets[1] then
        local chest = GameSave:CreateChest(position)	
        for i, gadget in ipairs(gadgets) do
            local Prototype = gadget._itemProperties.Prototype
            local gadgetID = CreateNewObject{prototypeName = Prototype, objName = "GameLoadGadget"..i.."_"..tostring(Prototype), belong = 1100}
            local gad = GetEntityByID(gadgetID)
            chest:AddChild(gad)
        end
    end
end
function GameSave:AddPlayerInventoryToChest(items, position)
    if items[1] then
		local DynScene = CurrentMap:DynamicSceneManager()
        local chest = GameSave:CreateChest(position)
        for i, item in ipairs(items) do
            local Property = item._itemProperties
            local itemID = CreateNewObject{prototypeName = Property.Prototype, objName = "GameLoadItem"..i.."_"..tostring(Property.ObjectId or "0"), belong = 1100}
            local itm = GetEntityByID(itemID)
            if DynScene:IsGUN(item) then
                DynScene:ApplyGunProperties(itm, item)
            end
            chest:AddChild(itm)
        end
    end
end

function GameSave:GiveQuestState()
	if CONFIG.LoadQuestState then
		LOG("[I] Module GameSave.lua === GameLoad:GiveQuestState()")
		local s = self
		local QuestManager = CurrentMap:QuestManager()

		for QuestName, Path in pairs(s.QuestMatrix or {}) do
			--repeat
				-- local SubQuests = QuestManager:IsQuestWithSubQuests(self.QuestIndex[QuestName])
				-- if SubQuests and not CONFIG.QuestState_LoadDifficultQuests then
				-- 	break
				-- end
				-- if not SubQuests and not CONFIG.QuestState_LoadSimpleQuests then
				-- 	break
				-- end
				for _, Command in ipairs(Path or {}) do
					local QuestScript = dostring("local f = function()\n "..Command.."\n end; return f")
					local s, e = pcall(QuestScript)
					if e then
						LOG("[E] Module GameSave.lua === QuestScript error! "..tostring(e))
					end
				end
			--until true
		end
		--частичное лечение TActivate внутри квестов
		for _, trigger in ipairs(s.InactiveTriggers or {}) do
			TDeactivate(trigger)
		end
	
		LOG("[I] Module GameSave.lua === Apply QuestState")
	end
end
function GameSave:GiveGUIInfo()
	LOG("[I] Module GameSave.lua === GameLoad:GiveGUIInfo()")
	local s = self
	--радар
	if CONFIG.GUI_LoadRadar then
		if Radar and s.RadarInfo then
			local RadarInfo = s.RadarInfo
			Radar:AllowNavPoints( RadarInfo.NavPointsAllowed )
			Radar:AllowVehicles( RadarInfo.VehiclesAllowed )
			Radar:AllowTurrets( RadarInfo.TurretsAllowed )
			Radar:AllowDistances( RadarInfo.DistancesAllowed )
			Radar:SetScanRadius( RadarInfo.ScanRadius )
		else
			SetRadarUpgrade(1)
		end
	end
	--известные уровни для игрока
	if CONFIG.GUI_LoadLevels then
		for i, levelName in ipairs(s.KnownLevels or {}) do
			AddKnownLevel( levelName )
		end
	end
	--истории
	if CONFIG.GUI_LoadHistory then
		for i, history in ipairs(s.JournalHistory or {}) do
			local name, time = history[1], history[2]
			local timeVal = str_gsub(time, " ", ", ")
			local timeFun = loadstring("g_ObjCont:SetGameTime("..timeVal..")")
			timeFun()
			AddHistory(name)
		end
	end
	--книги
	if CONFIG.GUI_LoadBooks then
		for i, book in ipairs(s.JournalBooks or {}) do
			AddBook(book)
		end
	end
	--энциклопедия
	if CONFIG.GUI_LoadEncyclopaedia then
		local Journal = GET_GLOBAL_OBJECT "Journal"
		if Journal then
			for i, clan in ipairs(s.JournalClans or {}) do
				Journal:AddClanToEncyclopaedia((tonumber(clan) or 1100))
			end
			for i, prototype in ipairs(s.JournalPrototypes or {}) do
				Journal:AddPrototypeToEncyclopaedia(prototype)
			end
		end
	end
	--квестовые предметы
	if CONFIG.GUI_LoadQuestItems then
		if not g_Player then
			LOG("[E] Module GameSave.lua === g_Player not found!!!")
			return nil
		end
		for i, questItem in ipairs(s.QuestItems or {}) do
			if not g_Player:IsQuestItemPresent(questItem) then
				g_Player:AddQuestItem(questItem)
			end
		end
	end

	--отношения группировок
	if CONFIG.GUI_LoadToleranceStatus then
		CurrentMap:ToleranceManager(s.Path.."\\"..CONFIG.Default_CurrentMap):Load()
	end

	LOG("[I] Module GameSave.lua === Apply GUIInfo")
end
function GameSave:GiveWeatherState()
	if CONFIG.LoadWeatherState then
		LOG("[I] Module GameSave.lua === GameLoad:GiveWeatherState()")
		local WeatherState = self.WeatherState or {id=0,time=0}

		SetWeather(WeatherState.id or 0)
		SetGameTime(WeatherState.time or 0, 0)

		UpdateWeather()

		LOG("[I] Module GameSave.lua === Apply WeatherState")
	end
end
function GameSave:GiveScriptState()
	LOG("[I] Module GameSave.lua === GameLoad:GiveScriptState()")
	local s = self

	--вары
	if CONFIG.Script_LoadVars then
		local Vars = s.Vars
		for i, var in ipairs(Vars or {}) do
			SetVar(var[1], var[2])
		end
	end
	--триггеры
	if CONFIG.Script_LoadTriggers then
		for _, trigger in ipairs(s.InactiveTriggers or {}) do
			TDeactivate(trigger)
		end
		for i, trigger in ipairs(s.Triggers or {}) do
			TDeactivate(trigger)
			TActivate(trigger)
		end
	end

	LOG("[I] Module GameSave.lua === Apply ScriptState")
end
function GameSave:GiveDynamicScene()
	LOG("[I] Module GameSave.lua === GameLoad:GiveDynamicScene()")
	local s = self
	local DynScene = CurrentMap:DynamicSceneManager()

    --игрок
    local Player = (s.Player and s.Player[1] or {})
    if CONFIG.Player_LoadMoney and Player._itemProperties then
        local Money = Player._itemProperties.Money
        if Money then
			if not g_Player then
				LOG("[E] Module GameSave.lua === g_Player not found!!!")
				return nil
			end
			g_Player:AddMoney(-1e10)
			g_Player:AddMoney((tonumber(Money) or 0))
        end
    end
    if CONFIG.Player_LoadVehicle and Player._itemProperties then
		LOG("[I] Module GameSave.lua === LoadPlayer...")
        local PlayerVehicle
        for i, child in ipairs(Player._itemChilds or {}) do
            if child._itemTag=="Object" then
                PlayerVehicle = child
                break
            end
        end

        if PlayerVehicle then
            local Property = PlayerVehicle._itemProperties

            AddPlayerVehicle(Property.Prototype or "Bug01")

            local Plv = GetPlayerVehicle()
            Plv:SetNameFromScript(Property.Name or "PlayerVehicle_0_0")

            Plv = DynScene:CreateAndSetVehicle(Plv, PlayerVehicle, true)

            local position, size = Plv:GetPosition(), Plv:GetSize()
            position.y = position.y + size.y + 1

            if CONFIG.Player_LoadInventory then
                local VehicleRepository = DynScene:GetVehicleRepository(PlayerVehicle)
                if VehicleRepository then
                    GameSave:AddPlayerInventoryToChest(VehicleRepository._itemChilds or {}, position)
                end
            end
            if CONFIG.Player_LoadGadgets then
                local VehicleGadgets = DynScene:GetVehicleGadgets(PlayerVehicle)
                if VehicleGadgets then
                    GameSave:AddPlayerGadgetsToChest(VehicleGadgets, position)
                end
            end
        else
            LOG("[E] Module GameSave.lua === PlayerVehicle object ERROR!")
        end
    end
	--инфекшены
	if CONFIG.DynamicScene_LoadInfection then
		LOG("[I] Module GameSave.lua === LoadInfection...")
		local InfectionTeams = s.InfectionTeams
		for i, Team in ipairs(InfectionTeams or {}) do
			DynScene:CreateAndSetTeam(nil, Team)
		end
	end
	--локации
	if CONFIG.DynamicScene_LoadLocations then
		LOG("[I] Module GameSave.lua === LoadLocations...")
		local Locations = s.Locations
        --LOG('locs\n'..table_debug(s.Locations))
		for i, Location in ipairs(Locations or {}) do
			DynScene:CreateAndSetLocation(Location)
		end
	end
	--тимы
	if CONFIG.DynamicScene_LoadTeams then
		LOG("[I] Module GameSave.lua === LoadTeams...")
		local Teams = s.Teams
		for i, Team in ipairs(Teams or {}) do
			DynScene:CreateAndSetTeam(nil, Team)
		end
	end
    --рандомные машины
    if CONFIG.DynamicScene_LoadVehicles then
		LOG("[I] Module GameSave.lua === LoadVehicles...")
		local Vehicles = s.Vehicles
        --LOG('vehs\n'..table_debug(s.Vehicles))
		for i, Vehicle in ipairs(Vehicles or {}) do
			DynScene:CreateAndSetVehicle(nil, Vehicle)
		end
	end
	--баррикады
	if CONFIG.DynamicScene_LoadBarricades then
		LOG("[I] Module GameSave.lua === LoadBarricades...")
		local Barricades = s.Dynamics
        --LOG('bars\n'..table_debug(s.Dynamics))
		for i, Barricade in ipairs(Barricades or {}) do
			DynScene:CreateAndSetBarricade(Barricade)
		end
	end
	--человечки
	if CONFIG.DynamicScene_LoadHumans then
		LOG("[I] Module GameSave.lua === LoadHumans...")
		local Humans = s.Humans
        --LOG('hums\n'..table_debug(s.Humans))
		for i, Human in ipairs(Humans or {}) do
			DynScene:CreateAndSetHuman(Human)
		end
	end
	--доты
	if CONFIG.DynamicScene_LoadDots then
		LOG("[I] Module GameSave.lua === LoadDots...")
		local Dots = s.Dots
        --LOG('dots\n'..table_debug(s.Dots))
		for i, Dot in ipairs(Dots or {}) do
			DynScene:CreateAndSetDot(Dot)
		end
	end
	--нпс
	if CONFIG.DynamicScene_LoadNPCsSpokenCounts then
		LOG("[I] Module GameSave.lua === LoadNPCsSpokenCounts...")
		local NPCs = s.NPCs
        --LOG('NPCs\n'..table_debug(s.NPCs))
		for i, NPC in ipairs(NPCs or {}) do
			DynScene:SetNPCsSpokenCount(NPC)
		end
	end
    --ящики
    if CONFIG.DynamicScene_LoadChests then
		LOG("[I] Module GameSave.lua === LoadChests...")
		local Chests = s.Chests
        --LOG('Chests\n'..table_debug(s.Chests))
		for i, Chest in ipairs(Chests or {}) do
			DynScene:CreateAndSetChest(Chest)
		end
	end
    --города
    if CONFIG.DynamicScene_LoadTowns then
		LOG("[I] Module GameSave.lua === LoadTowns...")
        local Towns = s.Towns	
        for i, Town in ipairs(Towns or {}) do
            DynScene:SetTownShops(Town)
        end
    end
	--оставшийся мусор
	if CONFIG.DynamicScene_LoadUnsortedObjects then
		LOG("[I] Module GameSave.lua === LoadUnsortedObjects...")
		local Unsorted = s.OtherNames
        --LOG('Unsorted\n'..table_debug(Unsorted))
		for i, Object in ipairs(Unsorted or {}) do
			local Property = Object._itemProperties
			local obj = DynScene:CreateAndSetObject(Object)
			if not obj then
				LOG("[E] Module GameSave.lua === Unsorted object ERROR!", Property.Name)
			end
		end
	end

	LOG("[I] Module GameSave.lua === Apply DynamicScene")
end
function GameSave:GiveCachedDynamic()
	LOG("[I] Module GameSave.lua === GameLoad:GiveCachedDynamic()")
	local s = self
	local DynScene = CurrentMap:DynamicSceneManager()
	if next(s.CachedDynamic_TownWorkshops) or next(s.CachedDynamic_TownShops) then
		local apply_item_properties = function(item, tbl_item, ShopName)
				local itemProperty = item._itemProperties
				local tbl_itemProperty = tbl_item._itemProperties
				--LOG(ShopName, "\n"..table_debug(item), "\n"..table_debug(tbl_item))
				local itemID = tonumber(itemProperty and itemProperty.ObjectId or item.ObjectId) or -1
				local itm = GetEntityByID(itemID)
				if itm and itm:GetProperty("Prototype").AsString == (tbl_itemProperty and tbl_itemProperty.Prototype or tbl_item.Prototype) then
					if DynScene:IsGUN(item) then
						DynScene:ApplyGunProperties(itm, tbl_item)
					else
						local Price = tonumber(tbl_itemProperty and tbl_itemProperty.Price or tbl_item.Price)
						local Affix = tostring(DynScene:GetItemAffix(tbl_item) or tbl_item.Affix)
						if Price then
							itm:SetProperty("Price", Price)
						end
						if Affix then
							itm:ApplyAffixByName(Affix)
						end
					end
				else
					LOG("[E] Module GameSave.lua === Violation of the loading order! Try gently repeat loading order. Exception > item ", itemID, "in", ShopName, " is nil")
				end
			end
		local apply_vehicle_properties = function(vehicle, tbl_vehicle, ShopName)
				local ObjectId = vehicle._itemProperties.ObjectId
				local veh = GetEntityByID( tonumber(ObjectId) or -1 )
				if DynScene:CreateAndSetVehicle(veh, tbl_vehicle, false) then
					--LOG("setted\n"..table_debug(vehicle._itemProperties))
				else
					LOG("[E] Module GameSave.lua === Violation of the loading order! Try gently repeat loading order. Exception > veh ", ObjectId, "in", ShopName, " is nil")
				end
			end

		for WorkshopName, Workshop in pairs(s.CachedDynamic_TownWorkshops or {}) do
			local xml_Workshop = XMLParser:ReadFromBigfile(s.LastSave_PATH, "Object", "Name", WorkshopName, 1)
			xml_Workshop = xml_Workshop and xml_Workshop[1]
			if xml_Workshop then
				local xml_CabinsAndBaskets, xml_Vehicles = DynScene:GetWorkshopItems(xml_Workshop)
				local tbl_CabinsAndBaskets, tbl_Vehicles = DynScene:GetWorkshopItems(Workshop)
				if t_getn(xml_CabinsAndBaskets)==t_getn(tbl_CabinsAndBaskets) and t_getn(xml_Vehicles)==t_getn(tbl_Vehicles) then
					for i, item in ipairs(xml_CabinsAndBaskets) do
						apply_item_properties(item, tbl_CabinsAndBaskets[i], WorkshopName)
					end
					for i, vehicle in ipairs(xml_Vehicles) do
						apply_vehicle_properties(vehicle, tbl_Vehicles[i], WorkshopName)
					end
				else
					LOG("[E] Module GameSave.lua === Violation of the loading order! Try gently repeat loading order. Exception \\/\\/\\/\n", WorkshopName, 'xml_CabinsAndBaskets\n'..table_debug(xml_CabinsAndBaskets), 'xml_Vehicles\n'..table_debug(xml_Vehicles), 'tbl_CabinsAndBaskets\n'..table_debug(tbl_CabinsAndBaskets), 'tbl_Vehicles\n'..table_debug(tbl_Vehicles))
				end
			end
		end
		for ShopName, Shop in pairs(s.CachedDynamic_TownShops or {}) do
			local xml_Shop = XMLParser:ReadFromBigfile(s.LastSave_PATH, "Object", "Name", ShopName, 1)
			xml_Shop = xml_Shop and xml_Shop[1]
			if xml_Shop then
				local xml_Items = DynScene:GetShopItems(xml_Shop)
				local tbl_Items = DynScene:GetShopItems(Shop)
				if t_getn(xml_Items)==t_getn(tbl_Items) then
					for i, item in ipairs(xml_Items) do
						apply_item_properties(item, tbl_Items[i], ShopName)
					end
				else
					LOG("[E] Module GameSave.lua === Violation of the loading order! Try gently repeat loading order. Exception \\/\\/\\/\n", ShopName, 'xml_Items\n'..table_debug(xml_Items), 'tbl_Items\n'..table_debug(tbl_Items))
				end
			end
		end

		LOG("[I] Module GameSave.lua === Apply CachedDynamic")

		File:Clean(true)
	end
end


--скрипт-корутина
function GameSave:FakeCoroutineScript()
    LOG("[I] Module GameSave.lua === GameLoad:FakeCoroutineScript()")

	LOG('Game loaded: "'..tostring(self.Path)..'\\maps'..'"')
	GS:UpdateLastSavePATH(SaveInfo.PATH)

    --восстановим состояния триггеров и вырубим их скриптом, чтобы не включались после сейвлоада
    local activeTriggers = self:SetLevelTriggersActivate()
    for i, triggerName in ipairs(activeTriggers) do
        TDeactivate(triggerName)
    end
	self:RemoveLevelCoroutineTrigger()

	--квесты
	self:GiveQuestState()

	--интерфейс
	self:GiveGUIInfo()

	--погода
	self:GiveWeatherState()

	--динамиксцена
	self:GiveDynamicScene()

	--удалим пути-заглушки
    if CONFIG.DynamicScene_LoadVehicles_ExternalPaths then
        self:RemoveLevelBlankExternalPaths()
    end

	--триггеры, вары
	self:GiveScriptState()

	--пользовательский скрипт
	self:LoadUserScript()

    --игра загружена
    AddImportantFadingMsgByStrIdFormatted("GameWasLoaded", self.SaveName)

	--очистка памяти
    File:Clean()
	LOG("[I] Module GameSave.lua === Game loaded!")
end
function GameSaveFakeCoroutineScript()
	return GameSave:FakeCoroutineScript()
end

--загрузчик
function GameSave:LoadGame()
    LOG("[I] Module GameSave.lua === GameLoad:LoadGame()")
	if File:Get() then
		local s = self
		local Path = CurrentMap.PATH

		LOG("[I] Module GameSave.lua === Save path: '"..Path.."'")

		--получаем инфу перед загрузкой
		s.LastSave_PATH 	= Path
		s.LevelName 		= SaveInfo.LevelName
		s.SaveName 			= SaveInfo.Name

		--интерфейс
		local Level = CurrentMap:LevelInfoManager()
		if CONFIG.GUI_LoadLevels then
			s.KnownLevels = Level:GetKnownLevels()
		end
		if CONFIG.LoadWeatherState then
			s.WeatherState = Level:GetWeatherState()
		end
		if CONFIG.GUI_LoadQuestItems then
			s.QuestItems = Level:GetQuestItems()
		end
		if CONFIG.GUI_LoadRadar then
			s.RadarInfo = CurrentMap:RadarWnd():GetRadar()
		end
		if CONFIG.GUI_LoadHistory then
			s.JournalHistory = CurrentMap:HistoryWnd():GetHistories()
		end
		if CONFIG.GUI_LoadBooks then
			s.JournalBooks = CurrentMap:BooksWnd():GetBooks()
		end
		if CONFIG.GUI_LoadEncyclopaedia then
			local Encyclo = CurrentMap:Encyclopaedia()
			s.JournalClans = Encyclo:GetClans()
			s.JournalPrototypes = Encyclo:GetPrototypes()
		end

		XMLParser:closeQueue()

		--динамиксцена
		local DynScene = CurrentMap:DynamicSceneManager()
		if CONFIG.Script_LoadTriggers then
			DynScene:CallTriggers()
			s.Triggers, s.InactiveTriggers = DynScene:GetSiftedActiveTriggers()
			if CONFIG.Script_LoadVars then
				s.Vars = DynScene:GetGlobalVars()
			end
		end
		if CONFIG.DynamicScene_LoadInfection then
        	s.InfectionZones = DynScene:CallInfectionZones()
        	s.InfectionTeams = DynScene:CallInfectionTeams()
		end
		if CONFIG.DynamicScene_LoadLocations then
			s.Locations = DynScene:CallLocations()
		end
		if CONFIG.DynamicScene_LoadTowns then
			s.Towns = DynScene:CallTowns()
		end
		if CONFIG.DynamicScene_LoadTeams then
			s.Teams = DynScene:CallTeams()
		end
		if CONFIG.DynamicScene_LoadVehicles then
			s.Vehicles = DynScene:CallVehicles()
		end
		if CONFIG.DynamicScene_LoadBarricades then
			s.Dynamics = DynScene:CallDynamics()
		end
		if CONFIG.DynamicScene_LoadHumans then
			s.Humans = DynScene:CallHumans()
		end
		if CONFIG.DynamicScene_LoadDots then
			s.Dots = DynScene:CallDots()
		end
		if CONFIG.DynamicScene_LoadNPCsSpokenCounts then
			s.NPCs = DynScene:CallNPCs()
		end
		if CONFIG.DynamicScene_LoadChests then
        	s.Chests = DynScene:CallChests()
		end
		if CONFIG.Player_LoadVehicle or CONFIG.Player_LoadMoney then
        	s.Player = DynScene:CallPlayer()
		end
		if CONFIG.DynamicScene_LoadUnsortedObjects then
			s.OtherNames = DynScene:CallOtherObjectsWithNames()
		end

        --пути-заглушки чтобы машинки продолжили ехать куда ехали
        if CONFIG.DynamicScene_LoadVehicles and CONFIG.DynamicScene_LoadVehicles_ExternalPaths then
            GameSave:SetLevelBlankExternalPaths()
        end

		--вырубаем мешающие триггеры на уровне файлов - те что врубаются сразу же с первой загрузкой карты (не активируйте триггеры через внешние файлы!)
		GameSave:SetLevelTriggersDeactivate()

		--триггер-корутина чтобы подождать загрузку карты
		GameSave:SetLevelCoroutineTrigger()

		--квесты
		if CONFIG.LoadQuestState then
			s.QuestMatrix = CurrentMap:QuestManager():GetQuestMatrix()
		end
		
		--грузим чистую карту и шаманим ДО КОНЦААА
		RuleConsole("/map "..s.LevelName)
	else
		LOG("[E] Module GameSave.lua === Loading files error!!!")
	end
end


-- /////////////////////////// RETURN MODULE ////////////////////////////////

LOG("[I] Module GameSave.lua "..GameSave.version.." successfully loaded.")

return GS