// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера      - АгентКластера    - ссылка на родительский объект агента кластера
//   Кластер            - Кластер        - ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.ОграниченияРесурсов);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список ограничений потребления ресурсов от утилиты администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Список"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка ограничений потребления ресурсов, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивОграничений = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивОграничений.Добавить(Новый ОграничениеРесурсов(Кластер_Агент, Кластер_Владелец, ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивОграничений);

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//    Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "Имя") Экспорт

	Возврат ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает список ограничений потребления ресурсов кластера 1С
//   
// Параметры:
//   Отбор                    - Структура    - Структура отбора ограничений потребления ресурсов (<поле>:<значение>)
//   ОбновитьПринудительно    - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Массив - список ограничений потребления ресурсов кластера 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	СписокОграничений = Элементы.Список(Отбор, ОбновитьПринудительно, ЭлементыКакСоответствия);
	
	Возврат СписокОграничений;

КонецФункции // Список()

// Функция возвращает ограничений потребления ресурсов кластера 1С
//   
// Параметры:
//   ПоляИерархии             - Строка       - Поля для построения иерархии списка ограничений потребления ресурсов,
//                                             разделенные ","
//   ОбновитьПринудительно    - Булево       - Истина - обновить список (вызов RAC)
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Соответствие - список ограничений потребления ресурсов кластера 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список ограничений потребления ресурсов
//                                                                        или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	СписокОграничений = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно, ЭлементыКакСоответствия);
	
	Возврат СписокОграничений;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество ограничений потребления ресурсов в списке
//   
// Возвращаемое значение:
//    Число - количество ограничений потребления ресурсов
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание ограничения потребления ресурсов кластера 1С
//   
// Параметры:
//   Имя                    - Строка    - Имя ограничения потребления ресурсов
//   ОбновитьПринудительно  - Булево    - Истина - принудительно обновить данные (вызов RAC)
//   КакСоответствие        - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание ограничения потребления ресурсов кластера 1С
//
Функция Получить(Знач Имя, Знач ОбновитьПринудительно = Ложь, КакСоответствие = Ложь) Экспорт

	ОбновитьДанные(ОбновитьПринудительно);

	Отбор = Новый Соответствие();
	Отбор.Вставить("name", Имя);

	Списокограничений = Элементы.Список(Отбор, ОбновитьПринудительно, КакСоответствие);
	
	Если Списокограничений.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Списокограничений[0];

КонецФункции // Получить()

// Процедура добавляет новый ограничение потребления ресурсов в кластер 1С
//   
// Параметры:
//   Имя                   - Строка        - имя ограничения потребления ресурсов 1С
//   ПараметрыОграничения  - Структура     - параметры ограничения потребления ресурсов 1С
//
Процедура Добавить(Имя, ПараметрыОграничения = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыОграничения) = Тип("Структура") Тогда
		ПараметрыОграничения = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	
	ПараметрыКоманды.Вставить("ИмяОграничения"           , Имя);

	Для Каждого ТекЭлемент Из ПараметрыОграничения Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	Если ПараметрыКоманды["Действие"] = Неопределено Тогда
		ПараметрыКоманды.Вставить("Действие"        , "none");
	КонецЕсли;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Изменить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка добавления ограничения потребления ресурсов ""%1"": %2",
	                                Имя,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Добавить()

// Процедура удаляет ограничение потребления ресурсов
//   
// Параметры:
//   Имя     - Строка   - Имя ограничения потребления ресурсов
//
Процедура Удалить(Знач Имя) Экспорт
	
	Если ТипЗнч(Имя) = Тип("Строка") Тогда
		Ограничение = Получить(Имя);
	КонецЕсли;

	Ограничение.Удалить();

	ОбновитьДанные(Истина);

КонецПроцедуры // Удалить()
