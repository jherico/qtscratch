//
//  Application.cpp
//  interface/src
//
//  Created by Andrzej Kapolka on 5/10/13.
//  Copyright 2013 High Fidelity, Inc.
//
//  Distributed under the Apache License, Version 2.0.
//  See the accompanying file LICENSE or http://www.apache.org/licenses/LICENSE-2.0.html
//

#include "Application.h"
#include <QMainWindow>
#include <QMenuBar>
#include <QDebug>
#include <QTimer>
#include <QScreen>
#include <QWindow>
#include <QDesktopWidget>

using namespace std;

Application::Application(int& argc, char** argv, QElapsedTimer &startup_time) :
    QApplication(argc, argv) { 
    _window = new QMainWindow(desktop());
    _menu = new QMenuBar();
    QActionGroup* screensGroup = new QActionGroup(this);
    auto menu = _menu->addMenu("Screen");
    foreach(auto screen, screens()) {
        QAction * action = new QAction(this);
        action->setText(screen->name());
        action->setCheckable(true);
        action->setChecked(false);
        action->setActionGroup(screensGroup);
        connect(action, &QAction::toggled, [=](bool active){
            setFullscreen(screen);
        });
        menu->addAction(action);
    }

    {
        QAction * action = new QAction(this);
        action->setText("Restore");
        action->setCheckable(true);
        action->setChecked(false);
        action->setActionGroup(screensGroup);
        connect(action, &QAction::toggled, [=](bool active) {
            unsetFullscreen();
        });
        menu->addAction(action);
    }
    _window->setMenuBar(_menu);
    _window->show();
}


Application::~Application() {
}


static QRect savedGeometry;
static QScreen* originalScreen = nullptr;

void Application::setFullscreen(const QScreen* target) {
    if (!_window->isFullScreen()) {
        savedGeometry = _window->geometry();
        originalScreen = _window->windowHandle()->screen();
        qDebug() << savedGeometry;
    }
    _window->windowHandle()->setScreen((QScreen*)target);
    _window->showFullScreen();
}

void Application::unsetFullscreen() {
    _window->showNormal();
    _window->setGeometry(savedGeometry);
}
