//
//  main.cpp
//  interface/src
//
//  Copyright 2013 High Fidelity, Inc.
//
//  Distributed under the Apache License, Version 2.0.
//  See the accompanying file LICENSE or http://www.apache.org/licenses/LICENSE-2.0.html
//

#include <QtGlobal>

#ifdef Q_OS_WIN32
#include <Windows.h>
#endif

#include <QCommandLineParser>
#include <QDebug>
#include <QDir>
#include <QSettings>
#include <QTranslator>
#include <QElapsedTimer>


#include "Application.h"


int main(int argc, const char* argv[]) {

    QElapsedTimer startupTime;
    startupTime.start();

    int exitCode;
    {
        QSettings::setDefaultFormat(QSettings::IniFormat);
        Application app(argc, const_cast<char**>(argv), startupTime);

        QTranslator translator;
        translator.load("interface_en");
        app.installTranslator(&translator);
        exitCode = app.exec();
    }
    return exitCode;
}   
