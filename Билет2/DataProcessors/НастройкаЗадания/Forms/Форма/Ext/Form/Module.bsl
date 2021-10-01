﻿
&НаКлиенте
Процедура СоздатьРегламент(Команда)
	СоздатьРегламентНаСервере();
КонецПроцедуры

&НаСервере
Процедура СоздатьРегламентНаСервере()
	
	Задания = РегламентныеЗадания.ПолучитьРегламентныеЗадания();
	Для каждого РегЗадание  Из Задания Цикл
	
		РегЗадание.удалить();
	
	КонецЦикла;
	
	РегЗад = РегламентныеЗадания.СоздатьРегламентноеЗадание(Метаданные.РегламентныеЗадания.СоздатьЕжедневныйОтчет);
	РегЗад.Использование = Истина;
	РегЗад.Наименование = "Создание ежедневных задач";
	
	Расписание = Новый РасписаниеРегламентногоЗадания;
	Расписание.ВремяНачала = ВремяНачала;
	Расписание.ПериодПовтораДней = 1;
	
	
	РегЗад.Расписание = Расписание;
	РегЗад.Записать();
	
КонецПроцедуры

&НаСервере
Процедура ТестНаСервере()
Задания.СоздатьЕжедневныйОтчет();
КонецПроцедуры

&НаКлиенте
Процедура Тест(Команда)
	ТестНаСервере();
КонецПроцедуры
