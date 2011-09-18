#ifndef PICTUREPLAYER_H
#define PICTUREPLAYER_H

#include "player.h"
#include <QObject>

class PicturePlayer : public Player
{
    Q_OBJECT
public:
    explicit PicturePlayer(QObject *parent = 0);

    QString namespaceString() const;
    Playlist *playlist() const;

public slots:
    void playPause();
    void moveUp();
    void moveDown();
    void moveLeft();
    void moveRight();
    void rotate();
    void skipNext();
    void skipPrevious();
    void stop();
    void zoomIn();
    void zoomOut();

    /**
      * Min: 1, Max: 10
      */
    void zoom(int level);
};

#endif // PICTUREPLAYER_H