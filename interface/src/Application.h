//
//  Application.h
//  interface/src
//
//  Created by Andrzej Kapolka on 5/10/13.
//  Copyright 2013 High Fidelity, Inc.
//
//  Distributed under the Apache License, Version 2.0.
//  See the accompanying file LICENSE or http://www.apache.org/licenses/LICENSE-2.0.html
//

#ifndef hifi_Application_h
#define hifi_Application_h

#include <QApplication>

class QElapsedTimer;
class QMainWindow;
class QMenuBar;

#if defined(qApp)
#undef qApp
#endif
#define qApp (static_cast<Application*>(QCoreApplication::instance()))

class Application : public QApplication {
    Q_OBJECT

public:
    Application(int& argc, char** argv, QElapsedTimer& startup_time);
    ~Application();

    virtual void setFullscreen(const QScreen* target);
    virtual void unsetFullscreen();

public:
    QMainWindow* _window;
    QMenuBar* _menu;

};

#endif // hifi_Application_h
