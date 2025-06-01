import React from 'react';
import {Route, Routes, Navigate} from 'react-router-dom';
import Header from './components/Header';
import ExpenseTracker from './pages/ExpenseTracker';
import Profile from './pages/Profile';



function App() {
  return(
    <>
      <Header />
      <Routes>
        <Route path="/" element={<Profile />} />
        <Route path="/expenses" element={<ExpenseTracker />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </>
  )
}


export default App;

