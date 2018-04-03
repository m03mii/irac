#Использовать 1testrunner

Процедура ПровестиТестирование()
	
	Тестер = Новый Тестер;

	КаталогПроекта = ОбъединитьПути(ТекущийСценарий().Каталог, "..");
	КаталогРезультатовТестов = Новый Файл(ОбъединитьПути(КаталогПроекта,"test-reports"));
	Если Не КаталогРезультатовТестов.Существует() Тогда
		СоздатьКаталог(КаталогРезультатовТестов.ПолноеИмя);
	КонецЕслИ;
	ФайлРезультатовТестовПакета = Новый Файл(КаталогРезультатовТестов.ПолноеИмя);
	КаталогТестов = Новый Файл(ОбъединитьПути(КаталогПроекта, "tests"));

	Тестер.ТестироватьКаталог(КаталогТестов, ФайлРезультатовТестовПакета);

КонецПроцедуры

ПровестиТестирование();
