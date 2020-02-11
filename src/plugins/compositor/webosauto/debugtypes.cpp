// Copyright (c) 2020 LG Electronics, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

#include "debugtypes.h"

class DebugTouchPointPrivate
{
public:
    inline DebugTouchPointPrivate(int id)
        : ref(1),
          id(id),
          state(DebugTouchPoint::TouchPointReleased)
    { }

    QAtomicInt ref;
    int id;
    QPointF normalizedPos;
    DebugTouchPoint::TouchPointState state;
};

DebugTouchPoint::DebugTouchPoint(int id)
    : QObject(nullptr)
    , d(new DebugTouchPointPrivate(id))
{
}

DebugTouchPoint::DebugTouchPoint(QObject *parent)
    : QObject(parent)
    , d(new DebugTouchPointPrivate(-1))
{
}

DebugTouchPoint::DebugTouchPoint(const DebugTouchPoint &other)
    : d(other.d)
{
    d->ref.ref();
}

DebugTouchPoint::~DebugTouchPoint()
{
    if (d && !d->ref.deref())
        delete d;
}

QPointF DebugTouchPoint::normalizedPos() const
{
    return d->normalizedPos;
}

void DebugTouchPoint::setNormalizedPos(const QPointF &normalizedPos)
{
    d->normalizedPos = normalizedPos;
}

DebugTouchPoint::TouchPointState DebugTouchPoint::state() const {
    return d->state;
}

void DebugTouchPoint::setState(Qt::TouchPointState state)
{
    switch (state) {
    case Qt::TouchPointPressed:
        d->state = TouchPointPressed;
        break;

    case Qt::TouchPointMoved:
        d->state = TouchPointMoved;
        break;

    case Qt::TouchPointStationary:
        d->state = TouchPointStationary;
        break;

    case Qt::TouchPointReleased:
        d->state = TouchPointReleased;
        break;
    }
}

DebugTouchEvent::DebugTouchEvent(QObject *parent)
    : QObject(parent)
{
}

DebugTouchEvent::DebugTouchEvent(const DebugTouchEvent &other)
{
    this->m_touchPoints = other._touchPoints();
}

DebugTouchEvent::~DebugTouchEvent()
{
    qDeleteAll(m_touchPoints.begin(), m_touchPoints.end());
}

QQmlListProperty<DebugTouchPoint> DebugTouchEvent::touchPoints()
{
    return QQmlListProperty<DebugTouchPoint>(this, m_touchPoints);
}

void DebugTouchEvent::appendDebugTouchPoint(DebugTouchPoint *point)
{
    m_touchPoints.append(point);
}
