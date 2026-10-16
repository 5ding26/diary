import React, { useEffect, useState } from 'react'
import dayjs from 'dayjs'

const WEATHER_API_KEY = 'REPLACE_WITH_YOUR_OPENWEATHERMAP_API_KEY'

export default function Editor({ initial, onClose, onSave }) {
  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')
  const [image, setImage] = useState(null)
  const [time, setTime] = useState(dayjs().format('YYYY-MM-DDTHH:mm'))
  const [weather, setWeather] = useState(null)
  const [loadingWeather, setLoadingWeather] = useState(false)

  useEffect(() => {
    if (initial) {
      setTitle(initial.title || '')
      setContent(initial.content || '')
      setImage(initial.image || null)
      setTime(dayjs(initial.datetime || Date.now()).format('YYYY-MM-DDTHH:mm'))
      setWeather(initial.weather || null)
    }
  }, [initial])

  function handleFile(e) {
    const f = e.target.files?.[0]
    if (!f) return
    const reader = new FileReader()
    reader.onload = () => setImage(reader.result)
    reader.readAsDataURL(f)
  }

  async function fetchWeather() {
    if (WEATHER_API_KEY === 'REPLACE_WITH_YOUR_OPENWEATHERMAP_API_KEY') {
      alert('请先在代码中替换 OpenWeatherMap API Key')
      return
    }

    if (!navigator.geolocation) {
      alert('此浏览器不支持定位')
      return
    }

    setLoadingWeather(true)
    navigator.geolocation.getCurrentPosition(async pos => {
      try {
        const lat = pos.coords.latitude
        const lon = pos.coords.longitude
        const url = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${WEATHER_API_KEY}&units=metric&lang=zh_cn`
        const res = await fetch(url)
        if (!res.ok) throw new Error('请求天气失败')
        const data = await res.json()
        setWeather({
          icon: mapIcon(data.weather?.[0]?.main),
          temp: Math.round(data.main?.temp || 0),
          desc: data.weather?.[0]?.description || ''
        })
      } catch (e) {
        alert('获取天气失败：' + e)
      } finally {
        setLoadingWeather(false)
      }
    }, err => {
      alert('定位失败：' + err.message)
      setLoadingWeather(false)
    })
  }

  function mapIcon(main) {
    if (!main) return '☁'
    const s = String(main).toLowerCase()
    if (s.includes('clear')) return '☀'
    if (s.includes('cloud')) return '⛅'
    if (s.includes('rain')) return '🌧'
    if (s.includes('snow')) return '❄'
    if (s.includes('mist') || s.includes('fog')) return '🌫'
    return '☁'
  }

  function handleSubmit() {
    const entry = {
      id: initial?.id || null,
      title: title || '无标题',
      content,
      image,
      time: dayjs(time).format('YYYY-MM-DD HH:mm'),
      datetime: dayjs(time).toISOString(),
      weather
    }
    onSave(entry)
  }

  return (
    <div className="modal">
      <div className="sheet">
        <div className="sheet-header">
          <h3>{initial ? '编辑日记' : '写日记'}</h3>
          <div>
            <button className="btn small" onClick={onClose}>取消</button>
            <button className="btn small primary" onClick={handleSubmit}>保存</button>
          </div>
        </div>

        <div className="sheet-body">
          <input className="input" placeholder="标题（可选）" value={title} onChange={e => setTitle(e.target.value)} />

          <div className="row">
            <input type="datetime-local" value={time} onChange={e => setTime(e.target.value)} />
            <button className="btn" onClick={fetchWeather}>{loadingWeather ? '获取中...' : '获取天气'}</button>
            <div className="weather-preview">{weather ? `${weather.icon} ${weather.temp}°` : '未获取天气'}</div>
          </div>

          <div className="row">
            <label className="filebtn">插入图片<input type="file" accept="image/*" onChange={handleFile} /></label>
            {image && <button className="link" onClick={() => setImage(null)}>移除</button>}
          </div>

          {image && <img src={image} alt="preview" className="preview" />}

          <textarea className="textarea" rows={10} placeholder="写下今天的点滴..." value={content} onChange={e => setContent(e.target.value)} />
        </div>
      </div>
    </div>
  )
}
