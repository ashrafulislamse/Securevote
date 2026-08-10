# Deploy SecureVote Web Portal to Vercel

## ✅ Build Test Passed
Your Next.js app builds successfully! Ready for deployment.

---

## Step 1: Push to GitHub

Your web portal needs to be in a GitHub repository. You mentioned: https://github.com/ashrafulislamse/Securevote

### Push the web portal folder:

```bash
cd securevote_web_portal

# Initialize git if not already done
git init

# Add all files
git add .

# Commit
git commit -m "Add SecureVote web portal for Vercel deployment"

# Add remote (replace with your repo URL)
git remote add origin https://github.com/ashrafulislamse/Securevote.git

# Push to GitHub
git push -u origin main
```

**Note:** If you want ONLY the web portal in the repo (not the whole project), you can create a separate repo just for the web portal.

---

## Step 2: Deploy to Vercel

### Option A: Using Vercel Dashboard (Easiest)

1. **Go to Vercel:** https://vercel.com
2. **Sign in** with GitHub
3. **Click "Add New Project"**
4. **Import your GitHub repository:** `ashrafulislamse/Securevote`
5. **Configure Project:**
   - Framework Preset: **Next.js** (auto-detected)
   - Root Directory: **securevote_web_portal** (if web portal is in subfolder)
   - Build Command: `npm run build` (auto-filled)
   - Output Directory: `.next` (auto-filled)
   - Install Command: `npm install` (auto-filled)
6. **Environment Variables** (if needed):
   - Click "Environment Variables"
   - Add any variables from `.env.example`
   - Example: `NEXT_PUBLIC_FIREBASE_API_KEY`, etc.
7. **Click "Deploy"**
8. **Wait 2-3 minutes** for deployment to complete
9. **Your site will be live at:** `https://your-project-name.vercel.app`

### Option B: Using Vercel CLI

```bash
# Install Vercel CLI globally
npm install -g vercel

# Navigate to web portal folder
cd securevote_web_portal

# Login to Vercel
vercel login

# Deploy
vercel

# Follow the prompts:
# - Set up and deploy? Yes
# - Which scope? Your account
# - Link to existing project? No
# - Project name? securevote-web-portal
# - Directory? ./
# - Override settings? No

# For production deployment
vercel --prod
```

---

## Step 3: Configure Custom Domain (Optional)

1. Go to your project in Vercel Dashboard
2. Click **Settings** → **Domains**
3. Add your custom domain (e.g., `admin.securevote.com`)
4. Follow DNS configuration instructions
5. Wait for DNS propagation (5-30 minutes)

---

## Step 4: Set Environment Variables in Vercel

If your app needs environment variables:

1. Go to **Project Settings** → **Environment Variables**
2. Add each variable:
   - Name: `NEXT_PUBLIC_FIREBASE_API_KEY`
   - Value: `your_actual_api_key`
   - Environment: Production, Preview, Development
3. Click **Save**
4. **Redeploy** the project to apply changes

---

## Troubleshooting

### Build Fails on Vercel

**Check:**
- Node version compatibility (Vercel uses Node 18+ by default)
- All dependencies are in `package.json`
- No missing environment variables
- Build works locally: `npm run build`

**Fix:**
```bash
# Test build locally first
cd securevote_web_portal
npm install
npm run build

# If successful, commit and push
git add .
git commit -m "Fix build issues"
git push
```

### Environment Variables Not Working

- Make sure variable names start with `NEXT_PUBLIC_` for client-side access
- Redeploy after adding variables
- Check variable names match exactly (case-sensitive)

### 404 Errors After Deployment

- Check your routes in `src/app/`
- Ensure all pages export default components
- Verify dynamic routes are properly configured

---

## Your Deployment URLs

After deployment, you'll get:

- **Production:** `https://securevote-web-portal.vercel.app`
- **Preview:** `https://securevote-web-portal-git-branch.vercel.app` (for each branch)
- **Custom Domain:** `https://your-domain.com` (if configured)

---

## Automatic Deployments

Vercel automatically deploys when you push to GitHub:

- **Push to `main` branch** → Production deployment
- **Push to other branches** → Preview deployment
- **Pull requests** → Preview deployment with unique URL

---

## Post-Deployment Checklist

✅ Site loads correctly  
✅ All pages accessible  
✅ Images and assets load  
✅ API calls work (if any)  
✅ Environment variables configured  
✅ Custom domain configured (if needed)  
✅ SSL certificate active (automatic)  
✅ Analytics configured (optional)

---

## Useful Vercel Commands

```bash
# Deploy to production
vercel --prod

# Check deployment status
vercel ls

# View logs
vercel logs

# Remove deployment
vercel rm [deployment-url]

# Link local project to Vercel project
vercel link
```

---

## Need Help?

- Vercel Docs: https://vercel.com/docs
- Next.js Deployment: https://nextjs.org/docs/deployment
- Vercel Support: https://vercel.com/support

---

**Your build is ready! Just push to GitHub and deploy on Vercel. It will work perfectly.** 🚀
