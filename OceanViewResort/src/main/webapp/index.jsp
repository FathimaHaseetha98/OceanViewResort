<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ocean View Resort - Luxury Beach Resort in Galle, Sri Lanka</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,400;0,700;1,400&display=swap" rel="stylesheet">

    <style>
        /* --- CSS VARIABLES & RESET --- */
        :root {
            --primary-gold: #c5a059;
            --primary-dark: #0a192f;
            --secondary-dark: #172a45;
            --text-light: #e6f1ff;
            --text-gray: #8892b0;
            --white: #ffffff;
            --transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body { 
            font-family: 'Montserrat', sans-serif; 
            background-color: #f4f4f4;
            color: var(--secondary-dark);
            line-height: 1.6;
            overflow-x: hidden;
        }

        h1, h2, h3, .brand {
            font-family: 'Playfair Display', serif;
        }

        /* --- NAVIGATION BAR --- */
        .navbar {
            background: rgba(10, 25, 47, 0.85);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            padding: 20px 5%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 1000;
            border-bottom: 1px solid rgba(197, 160, 89, 0.2);
            transition: var(--transition);
        }

        .navbar .brand { 
            color: var(--white); 
            font-size: 26px; 
            font-weight: 700; 
            letter-spacing: 1px;
        }

        .navbar .nav-links {
            display: flex;
            align-items: center;
            gap: 30px;
        }

        .navbar .nav-links a {
            color: var(--text-light);
            text-decoration: none;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 500;
            transition: var(--transition);
            position: relative;
        }

        .navbar .nav-links a:not(.btn-staff)::after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: -5px;
            left: 0;
            background-color: var(--primary-gold);
            transition: var(--transition);
        }

        .navbar .nav-links a:not(.btn-staff):hover { color: var(--primary-gold); }
        .navbar .nav-links a:not(.btn-staff):hover::after { width: 100%; }

        .navbar .btn-staff {
            background: transparent;
            color: var(--primary-gold);
            padding: 8px 20px;
            border: 1px solid var(--primary-gold);
            border-radius: 0; /* Sharp edges for premium feel */
            font-size: 12px;
            text-transform: uppercase;
        }

        .navbar .btn-staff:hover {
            background: var(--primary-gold);
            color: var(--primary-dark);
        }
        
        /* --- HERO SECTION --- */
        .hero {
            /* Parallax Effect */
            background: linear-gradient(rgba(10, 25, 47, 0.7), rgba(10, 25, 47, 0.4)), 
                        url('https://images.unsplash.com/photo-1544124499-58912cbddaad?auto=format&fit=crop&w=1920&q=80');
            height: 90vh;
            background-size: cover;
            background-position: center;
            background-attachment: fixed; /* Creates parallax */
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: white;
            text-align: center;
            position: relative;
        }

        .hero h1 { 
            font-size: 3.5rem; 
            margin-bottom: 20px; 
            font-weight: 400;
            letter-spacing: 2px;
            animation: fadeUp 1s ease-out;
        }

        .hero p { 
            font-size: 1.2rem; 
            margin-bottom: 40px; 
            max-width: 600px;
            font-weight: 300;
            color: #e0e0e0;
            animation: fadeUp 1.2s ease-out;
        }

        .hero .cta-buttons {
            animation: fadeUp 1.4s ease-out;
        }

        .hero .cta-buttons a {
            display: inline-block;
            margin: 0 15px;
            padding: 15px 40px;
            text-decoration: none;
            text-transform: uppercase;
            font-size: 13px;
            letter-spacing: 2px;
            font-weight: 600;
            transition: var(--transition);
        }

        /* Gold Button */
        .hero .btn-primary {
            background: var(--primary-gold);
            color: var(--primary-dark);
            border: 2px solid var(--primary-gold);
        }
        .hero .btn-primary:hover {
            background: transparent;
            color: var(--white);
        }

        /* Transparent Button */
        .hero .btn-secondary {
            background: transparent;
            color: var(--white);
            border: 2px solid var(--white);
        }
        .hero .btn-secondary:hover {
            background: var(--white);
            color: var(--primary-dark);
        }
        
        /* --- ROOMS SECTION --- */
        .section-title {
            text-align: center;
            padding: 100px 20px 20px;
            font-size: 2.5rem;
            color: var(--primary-dark);
            position: relative;
        }
        
        .section-title::after {
            content: '';
            display: block;
            width: 60px;
            height: 3px;
            background: var(--primary-gold);
            margin: 20px auto 0;
        }

        .rooms {
            display: flex;
            justify-content: center;
            gap: 40px;
            padding: 40px 5% 100px;
            flex-wrap: wrap;
            background: #f4f4f4;
        }

        .room-card {
            flex: 1 1 350px; /* Responsive flex */
            max-width: 400px;
            background: var(--white);
            border-radius: 4px;
            box-shadow: 0 10px 30px -15px rgba(2, 12, 27, 0.1);
            overflow: hidden;
            transition: var(--transition);
            cursor: pointer;
            position: relative;
            display: flex;
            flex-direction: column;
        }

        .room-card:hover {
            transform: translateY(-15px);
            box-shadow: 0 20px 30px -15px rgba(2, 12, 27, 0.2);
        }

        /* Image Wrapper hack using existing HTML */
        .room-card img {
            width: 100%;
            height: 280px;
            object-fit: cover;
            transition: transform 0.8s ease;
        }

        .room-card:hover img {
            transform: scale(1.05);
        }

        .room-card .content {
            padding: 35px;
            text-align: center;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .room-card h3 { 
            color: var(--primary-dark); 
            margin-bottom: 15px; 
            font-size: 1.5rem;
        }

        .room-card p { 
            color: #666; 
            font-size: 0.95rem; 
            margin-bottom: 20px;
            font-weight: 300;
        }

        .room-card .price {
            font-family: 'Playfair Display', serif;
            font-size: 1.4rem;
            color: var(--primary-gold);
            font-weight: 700;
            margin: 10px 0 25px;
            border-top: 1px solid #eee;
            border-bottom: 1px solid #eee;
            padding: 10px 0;
        }

        .room-card .btn-book {
            display: inline-block;
            background: var(--primary-dark);
            color: var(--white);
            padding: 15px 0;
            width: 100%;
            text-decoration: none;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 2px;
            font-weight: 600;
            transition: var(--transition);
        }

        .room-card .btn-book:hover { 
            background: var(--primary-gold); 
        }
        
        /* --- FOOTER --- */
        .footer {
            background: var(--primary-dark);
            color: var(--text-gray);
            text-align: center;
            padding: 60px 20px;
            border-top: 3px solid var(--primary-gold);
        }

        .footer p {
            margin-bottom: 15px;
            font-size: 0.9rem;
            letter-spacing: 0.5px;
        }

        .footer a { 
            color: var(--primary-gold); 
            text-decoration: none; 
            transition: var(--transition);
        }
        
        .footer a:hover {
            color: var(--white);
            text-decoration: underline;
        }

        /* --- KEYFRAMES --- */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* --- MOBILE TWEAKS --- */
        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                padding: 15px;
            }
            .navbar .nav-links {
                margin-top: 15px;
                flex-wrap: wrap;
                justify-content: center;
            }
            .hero h1 { font-size: 2.5rem; }
            .hero .cta-buttons { display: flex; flex-direction: column; gap: 15px; }
        }
    </style>
</head>
<body>
    <div class="navbar">
        <div class="brand">Ocean View Resort</div>
        <div class="nav-links">
            <a href="index.jsp">Home</a>
            <a href="guest_register.jsp">Register</a>
            <a href="guest_login.jsp">Guest Login</a>
            <a href="stafflogin.jsp" class="btn-staff">Staff Portal</a>
        </div>
    </div>

    <div class="hero">
        <h1>Escape to Paradise</h1>
        <p>Experience refined luxury, bespoke comfort, and breathtaking ocean horizons in the heart of Galle.</p>
        <div class="cta-buttons">
            <a href="guest_register.jsp" class="btn-primary">Begin Journey</a>
            <a href="guest_login.jsp" class="btn-secondary">Guest Login</a>
        </div>
    </div>

    <h2 class="section-title">The Collection</h2>
    <div class="rooms">
        <div class="room-card">
            <img src="https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=800&q=80" alt="Standard Room">
            <div class="content">
                <h3>Standard Room</h3>
                <p>An intimate sanctuary for solo travelers or couples. Featuring plush bedding, modern amenities, and garden views.</p>
                <p class="price">LKR 5,000 <span style="font-size:0.7em; color:#999; font-weight:400">/ Night</span></p>
                <a href="guest_login.jsp" class="btn-book">View Details</a>
            </div>
        </div>
        
        <div class="room-card">
            <img src="https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80" alt="Deluxe Room">
            <div class="content">
                <h3>Ocean Deluxe</h3>
                <p>Spacious elegance meets the horizon. Enjoy a private balcony, premium bath amenities, and stunning ocean vistas.</p>
                <p class="price">LKR 8,500 <span style="font-size:0.7em; color:#999; font-weight:400">/ Night</span></p>
                <a href="guest_login.jsp" class="btn-book">View Details</a>
            </div>
        </div>
        
        <div class="room-card">
            <img src="https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=800&q=80" alt="Luxury Suite">
            <div class="content">
                <h3>Royal Suite</h3>
                <p>The pinnacle of resort living. Panoramic views, private jacuzzi, personalized butler service, and VIP lounge access.</p>
                <p class="price">LKR 15,000 <span style="font-size:0.7em; color:#999; font-weight:400">/ Night</span></p>
                <a href="guest_login.jsp" class="btn-book">View Details</a>
            </div>
        </div>
    </div>

    <div class="footer">
        <div class="brand" style="margin-bottom: 20px; font-size: 24px; color: #fff;">Ocean View Resort</div>
        <p>&copy; 2026 Ocean View Resort, Galle, Sri Lanka. All rights reserved.</p>
        <p>Concierge: +94 91 222 3456 | <a href="mailto:info@oceanviewresort.lk">info@oceanviewresort.lk</a></p>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = 1;
                        entry.target.style.transform = "translateY(0)";
                    }
                });
            });

            // Add simple fade-in to cards on scroll
            const cards = document.querySelectorAll('.room-card');
            cards.forEach((card, index) => {
                card.style.opacity = 0;
                card.style.transform = "translateY(30px)";
                card.style.transition = `all 0.6s ease ${index * 0.2}s`; // Staggered delay
                observer.observe(card);
            });
        });
    </script>
</body>
</html>