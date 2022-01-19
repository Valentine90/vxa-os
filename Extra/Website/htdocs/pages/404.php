	<style type="text/css">
	    p,
	    h1,
	    h2,
	    h3,
	    h4,
	    h5 {
	        margin: 0;
	    }



	    .error-wrapper {
	        left: 50%;
	        top: 100%;
	        text-align: center;
	    }

	    .error-wrapper .title {
	        font-size: 32px;
	        font-weight: 700;
	        color: #000;
	    }

	    .error-wrapper .info {
	        font-size: 14px;
	    }

	    .home-btn,
	    .home-btn:focus,
	    .home-btn:hover,
	    .home-btn:visited {
	        text-decoration: none;
	        font-size: 14px;
	        color: #55aa29;
	        padding: 17px 77px;
	        border: 1px solid #55aa29;
	        -webkit-border-radius: 3px;
	        -moz-border-radius: 3px;
	        -o-border-radius: 3px;
	        border-radius: 3px;
	        display: block;
	        margin: 20px 0;
	        width: max-content;
	        background-color: transparent;
	        outline: 0;
	    }

	    .man-icon {
	        background: url('https://www.hotstar.com/assets/b5e748831c911ca02f9c07afc11f2ae5.svg') center center no-repeat;
	        display: inline-block;
	        height: 100px;
	        width: 118px;
	        margin-bottom: 16px;
	    }
	</style>

	<div class="error-wrapper">
	    <div class="man-icon"></div>
	    <h3 class="title">404</h3>
	    <p class="info"><?php echo $lang['404']; ?></p>
	</div>