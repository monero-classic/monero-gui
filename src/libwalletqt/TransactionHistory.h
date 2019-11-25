#ifndef TRANSACTIONHISTORY_H
#define TRANSACTIONHISTORY_H

#include <QObject>
#include <QList>
#include <QDateTime>

#define CRYPTONOTE_MAX_BLOCK_NUMBER 500000000

namespace Monero {
class TransactionHistory;
}

class TransactionInfo;

class TransactionHistory : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count)
    Q_PROPERTY(QDateTime firstDateTime READ firstDateTime NOTIFY firstDateTimeChanged)
    Q_PROPERTY(QDateTime lastDateTime READ lastDateTime NOTIFY lastDateTimeChanged)
    Q_PROPERTY(int minutesToUnlock READ minutesToUnlock)
    Q_PROPERTY(bool locked READ locked)
    Q_PROPERTY(int blockToUnlock READ blockToUnlock)

public:
    Q_INVOKABLE TransactionInfo *transaction(int index);
    Q_INVOKABLE TransactionInfo *lockedTx(int index);
    // Q_INVOKABLE TransactionInfo * transaction(const QString &id);
    Q_INVOKABLE QList<TransactionInfo*> getAll(quint32 accountIndex) const;
    Q_INVOKABLE void refresh(quint32 accountIndex);
    Q_INVOKABLE QString writeCSV(quint32 accountIndex, QString out);
    Q_INVOKABLE QList<TransactionInfo*> getLockedIncoming(quint32 accountIndex, quint64 unlocktime) const;
    quint64 count() const;
    quint64 lockedCount() const;
    QDateTime firstDateTime() const;
    QDateTime lastDateTime() const;
    quint64 minutesToUnlock() const;
    bool locked() const;
    quint64 blockToUnlock() const;

signals:
    void refreshStarted() const;
    void refreshFinished() const;
    void firstDateTimeChanged() const;
    void lastDateTimeChanged() const;
    void lockedIncomingUpdated(QList<TransactionInfo*>&) const;

private:
    bool isTxLocked(quint64 block_height, quint64 block_time, quint64 tx_unlock_time, quint64 unlock_time) const;

public slots:


private:
    explicit TransactionHistory(Monero::TransactionHistory * pimpl, QObject *parent = 0);

private:
    friend class Wallet;
    Monero::TransactionHistory * m_pimpl;
    mutable QList<TransactionInfo*> m_tinfo;
    mutable QList<TransactionInfo*> m_lockedinfo;
    mutable QDateTime   m_firstDateTime;
    mutable QDateTime   m_lastDateTime;
    mutable int m_minutesToUnlock;
    mutable int m_blockToUnlock;
    // history contains locked transfers
    mutable bool m_locked;

};

#endif // TRANSACTIONHISTORY_H
