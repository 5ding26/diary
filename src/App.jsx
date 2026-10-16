import React, { useEffect, useState } from 'react'
import Editor from './components/Editor'

const STORAGE_KEY = 'diary_entries_v1'

export default function App() {
  const [entries, setEntries] = useState([])
  const [showEditor, setShowEditor] = useState(false)
  const [editing, setEditing] = useState(null)

  useEffect(() => {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) setEntries(JSON.parse(raw))
  }, [])

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(entries))
  }, [entries])

  function handleSave(entry) {
    if (entry.id) {
      setEntries(prev => prev.map(e => e.id === entry.id ? entry : e))
    } else {
      entry.id = String(Date.now())
      setEntries(prev => [entry, ...prev])
    }
    setShowEditor(false)
    setEditing(null)
  }

  function handleDelete(id) {
    if (!confirm('确认删除这条日记吗？')) return
    setEntries(prev => prev.filter(e => e.id !== id))
  }

  return (
    <div className="page">
      <header className="topbar">
        <h1>唯美日记（Web）</h1>
        <button className="btn" onClick={() => { setShowEditor(true); setEditing(null) }}>写日记</button>
      </header>

      <main className="container">
        {entries.length === 0 && (
          <div className="empty">
            <p>还没有日记，点击「写日记」开始记录你的日常。</p>
          </div>
        )}

        <div className="list">
          {entries.map(entry => (
            <article key={entry.id} className="card">
              <div className="card-header">
                <div className="time">{entry.time}</div>
                <div className="meta">{entry.weather?.icon ?? ''} {entry.weather?.temp ?? ''}</div>
              </div>
              <h2 className="title">{entry.title}</h2>
              {entry.image && <img src={entry.image} alt="attachment" className="cover" />}
              <p className="excerpt">{entry.content}</p>
              <div className="actions">
                <button className="link" onClick={() => { setEditing(entry); setShowEditor(true) }}>编辑</button>
                <button className="link danger" onClick={() => handleDelete(entry.id)}>删除</button>
              </div>
            </article>
          ))}
        </div>
      </main>

      {showEditor && (
        <Editor
          initial={editing}
          onClose={() => { setShowEditor(false); setEditing(null) }}
          onSave={handleSave}
        />
      )}

      <footer className="footer">数据保存在本地浏览器，不会上传。要开启天气功能，请在写作界面点击“获取天气”并允许位置权限。</footer>
    </div>
  )
}
